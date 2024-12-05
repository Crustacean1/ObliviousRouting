/*
 * SPDX-License-Identifier: GPL-2.0-only
 */

#include "ns3/applications-module.h"
#include "ns3/core-module.h"
#include "ns3/internet-module.h"
#include "ns3/network-module.h"
#include "ns3/point-to-point-module.h"

// Default Network Topology
//
//       10.1.1.0
// n0 -------------- n1
//    point-to-point
//

using namespace ns3;

NS_LOG_COMPONENT_DEFINE("ObliviousApp");

class ObliviousApp : public Application
{
    EventId m_event;
    Ptr<ns3::Socket> m_socket;
    ns3::Address m_peer;
    ns3::Address m_local;
    uint32_t m_size = 0; //!< Size of the sent packet

  public:
    TracedCallback<Ptr<const Packet>> m_txTrace;

    /// Callbacks for tracing the packet Rx events
    TracedCallback<Ptr<const Packet>> m_rxTrace;

    /// Callbacks for tracing the packet Tx events, includes source and destination addresses
    TracedCallback<Ptr<const Packet>, const Address&, const Address&> m_txTraceWithAddresses;

    /// Callbacks for tracing the packet Rx events, includes source and destination addresses
    TracedCallback<Ptr<const Packet>, const Address&, const Address&> m_rxTraceWithAddresses;

    ObliviousApp()
    {
        NS_LOG_FUNCTION(this);
    }

    static TypeId GetTypeId()
    {
        static TypeId tid =
            TypeId("ns3::ObliviousApp")
                .SetParent<Application>()
                .SetGroupName("Applications")
                .AddConstructor<ObliviousApp>()
                .AddAttribute("Peer",
                              "Address of a peer(s)",
                              AddressValue(),
                              MakeAddressAccessor(&ObliviousApp::m_peer),
                              MakeAddressChecker())
                .AddTraceSource("Tx",
                                "A new packet is created and is sent",
                                MakeTraceSourceAccessor(&ObliviousApp::m_txTrace),
                                "ns3::Packet::TracedCallback")
                .AddTraceSource("Rx",
                                "A packet has been received",
                                MakeTraceSourceAccessor(&ObliviousApp::m_rxTrace),
                                "ns3::Packet::TracedCallback")
                .AddTraceSource("TxWithAddresses",
                                "A new packet is created and is sent",

                                MakeTraceSourceAccessor(&ObliviousApp::m_txTraceWithAddresses),
                                "ns3::Packet::TwoAddressTracedCallback")
                .AddTraceSource("RxWithAddresses",
                                "A packet has been received",
                                MakeTraceSourceAccessor(&ObliviousApp::m_rxTraceWithAddresses),
                                "ns3::Packet::TwoAddressTracedCallback");
        return tid;
    }

    void StartApplication() override
    {
        NS_LOG_FUNCTION(this);

        if (!m_socket)
        {
            Ptr<Ipv6> ipv6 = GetNode()->GetObject<Ipv6>();
            auto no_interfaces = ipv6->GetNInterfaces();
            NS_LOG_INFO("Number of interfaces");
            NS_LOG_INFO(no_interfaces);
            for (int i = 0; i < no_interfaces; i++)
            {
                NS_LOG_INFO("Found interface:");
                auto address_count = ipv6->GetNAddresses(i);
                for (int j = 0; j < address_count; j++)
                {
                    NS_LOG_INFO(ipv6->GetAddress(i, j));
                }
            }
            NS_LOG_INFO("Peer addr:");
            auto tid = TypeId::LookupByName("ns3::UdpSocketFactory");
            m_socket = Socket::CreateSocket(GetNode(), tid);
            auto address = Inet6SocketAddress(Ipv6Address::GetAny(), 1234);
            if (m_socket->Bind(address) == -1)
            {
                NS_FATAL_ERROR("Failed to bind socket");
            }

            m_socket->SetRecvCallback(MakeCallback(&ObliviousApp::HandleRead, this));
            m_socket->SetAllowBroadcast(true);
        }

        if (!m_peer.IsInvalid())
        {
            m_peer = addressUtils::ConvertToSocketAddress(m_peer, 1234);
            NS_LOG_INFO("My peer ip");
            NS_LOG_INFO(m_peer);
            if (m_socket->Connect(m_peer) == -1)
            {
                NS_FATAL_ERROR("Failed to connect");
            }
            ScheduleTransmit(Seconds(1.));
        }
    }

    void ScheduleTransmit(Time dt)
    {
        NS_LOG_FUNCTION(this << dt);
        m_event = Simulator::Schedule(dt, &ObliviousApp::Send, this);
    }

    void HandleRead(Ptr<Socket> socket)
    {
        NS_LOG_FUNCTION(this << socket);
        Address from;
        while (auto packet = socket->RecvFrom(from))
        {
            if (Inet6SocketAddress::IsMatchingType(from))
            {
                NS_LOG_INFO("At time " << Simulator::Now().As(Time::S) << " client received "
                                       << packet->GetSize() << " bytes from "
                                       << Inet6SocketAddress::ConvertFrom(from).GetIpv6()
                                       << " port "
                                       << Inet6SocketAddress::ConvertFrom(from).GetPort());
            }
            Address localAddress;
            socket->GetSockName(localAddress);
            m_rxTrace(packet);
            m_rxTraceWithAddresses(packet, from, localAddress);
        }
    }

    void Send()
    {
        NS_LOG_FUNCTION(this);

        NS_ASSERT(m_event.IsExpired());

        Ptr<Packet> p = Create<Packet>(m_size);
        Address localAddress;
        m_socket->GetSockName(localAddress);

        m_txTrace(p);
        m_txTraceWithAddresses(p, localAddress, m_peer);

        m_socket->Send(p);
        if (Inet6SocketAddress::IsMatchingType(m_peer))
        {
            NS_LOG_INFO("At time " << Simulator::Now().As(Time::S) << " client sent " << m_size
                                   << " bytes to "
                                   << Inet6SocketAddress::ConvertFrom(m_peer).GetIpv6() << " port "
                                   << Inet6SocketAddress::ConvertFrom(m_peer).GetPort());
        }
    }

    void StopApplication() override
    {
        NS_LOG_INFO("Stopping application");
    }

    ~ObliviousApp() override
    {
    }

    void OnRecv(Ptr<Socket> socket)
    {
        NS_LOG_INFO("Receiving message");
    }
};

class StackHelper
{
  public:
    /**
     * \brief Add an address to a IPv6 node.
     * \param n node
     * \param interface interface index
     * \param address IPv6 address to add
     */
    inline void AddAddress(Ptr<Node>& n, uint32_t interface, Ipv6Address address)
    {
        Ptr<Ipv6> ipv6 = n->GetObject<Ipv6>();
        ipv6->AddAddress(interface, address);
    }

    /**
     * \brief Print the routing table.
     * \param n the node
     */
    inline void PrintRoutingTable(Ptr<Node>& n)
    {
        Ptr<Ipv6StaticRouting> routing = nullptr;
        Ipv6StaticRoutingHelper routingHelper;
        Ptr<Ipv6> ipv6 = n->GetObject<Ipv6>();
        uint32_t nbRoutes = 0;
        Ipv6RoutingTableEntry route;

        routing = routingHelper.GetStaticRouting(ipv6);

        std::cout << "Routing table of " << n << " : " << std::endl;
        std::cout << "Destination\t\t\t\t"
                  << "Gateway\t\t\t\t\t"
                  << "Interface\t"
                  << "Prefix to use" << std::endl;

        nbRoutes = routing->GetNRoutes();
        for (uint32_t i = 0; i < nbRoutes; i++)
        {
            route = routing->GetRoute(i);
            std::cout << route.GetDest() << "\t\t\t\t\t" << route.GetGateway() << "\t\t\t\t\t"
                      << route.GetInterface() << "\t\t\t\t\t" << route.GetPrefixToUse()
                      << "\t\t\t\t\t" << std::endl;
        }
    }
};

class ObliviousRouting : public Ipv6RoutingProtocol
{
  public:
    ~ObliviousRouting() override
    {
    }

    ObliviousRouting()
    {
    }

    static TypeId GetTypeId()
    {
        static auto tid = TypeId("ns3::ObliviousRouting")
                              .SetParent<Ipv6RoutingProtocol>()
                              .SetGroupName("Internet")
                              .AddConstructor<ObliviousRouting>();
        return tid;
    }

    Ptr<Ipv6Route> RouteOutput(Ptr<Packet> p,
                               const Ipv6Header& header,
                               Ptr<NetDevice> oif,
                               Socket::SocketErrno& sockerr) override
    {
        NS_LOG_INFO("Routing output");
        return nullptr;
    }

    bool RouteInput(Ptr<const Packet> p,
                    const Ipv6Header& header,
                    Ptr<const NetDevice> idev,
                    const UnicastForwardCallback& ucb,
                    const MulticastForwardCallback& mcb,
                    const LocalDeliverCallback& lcb,
                    const ErrorCallback& ecb) override
    {
        NS_LOG_INFO("Routing input");
        return false;
    }

    void NotifyInterfaceUp(uint32_t interface) override
    {
        NS_LOG_INFO("Interface up");
    }

    void NotifyInterfaceDown(uint32_t interface) override
    {
        NS_LOG_INFO("Interface down");
    }

    void NotifyAddAddress(uint32_t interface, Ipv6InterfaceAddress address) override
    {
        NS_LOG_INFO("Add address");
    }

    void NotifyRemoveAddress(uint32_t interface, Ipv6InterfaceAddress address) override
    {
        NS_LOG_INFO("Remove address");
    }

    void NotifyAddRoute(Ipv6Address dst,
                        Ipv6Prefix mask,
                        Ipv6Address nextHop,
                        uint32_t interface,
                        Ipv6Address prefixToUse = Ipv6Address::GetZero()) override
    {
        NS_LOG_INFO("Route addded");
    }

    void NotifyRemoveRoute(Ipv6Address dst,
                           Ipv6Prefix mask,
                           Ipv6Address nextHop,
                           uint32_t interface,
                           Ipv6Address prefixToUse = Ipv6Address::GetZero()) override
    {
        NS_LOG_INFO("Route removed");
    }

    void SetIpv6(Ptr<Ipv6> ipv6) override
    {
        NS_LOG_INFO("Setting ipv6");
    }

    void PrintRoutingTable(Ptr<OutputStreamWrapper> stream,
                           Time::Unit unit = Time::S) const override
    {
        NS_LOG_INFO("PRINTING");
    }
};

class ObliviousRoutingHelper : public Ipv6RoutingHelper
{
  public:
    ObliviousRoutingHelper()
    {
    }

    ~ObliviousRoutingHelper() override
    {
    }

    ObliviousRoutingHelper(const ObliviousRoutingHelper& o)
    {
        NS_LOG_INFO("COPYING CONSTR");
    }

    ObliviousRoutingHelper& operator=(const ObliviousRoutingHelper&) = delete;

    ObliviousRoutingHelper* Copy() const override
    {
        NS_LOG_INFO("COPYING");
        return new ObliviousRoutingHelper();
    }

    void Add(const Ipv6RoutingHelper& routing, int16_t priority)
    {
        NS_LOG_INFO("ADDING");
    }

    Ptr<Ipv6RoutingProtocol> Create(Ptr<Node> node) const override
    {
        new ObliviousRouting();
        return CreateObject<ObliviousRouting>();
    }

  private:
    std::list<std::pair<const Ipv6RoutingHelper*, int16_t>> m_list;
};

int
main(int argc, char* argv[])

{
    CommandLine cmd(__FILE__);
    // uint32_t dimensions;
    // cmd.AddValue("dimensions", "Number of hypercube dimensions", dimensions);
    // cmd.Parse(argc, argv);

    StackHelper stackHelper;

    Time::SetResolution(Time::NS);
    LogComponentEnable("ObliviousApp", LOG_LEVEL_INFO);

    AsciiTraceHelper ascii;

    NodeContainer nodes;
    nodes.Create(3);

    Ipv6StaticRoutingHelper routingHelper;
    InternetStackHelper stack;
    stack.SetRoutingHelper(routingHelper);
    stack.Install(nodes);

    PointToPointHelper p2p;
    p2p.SetDeviceAttribute("DataRate", StringValue("5Mbps"));
    p2p.SetChannelAttribute("Delay", StringValue("2ms"));

    NetDeviceContainer devices;
    auto devices1 = p2p.Install(nodes.Get(0), nodes.Get(1));
    auto devices2 = p2p.Install(nodes.Get(1), nodes.Get(2));
    // auto devices3 = p2p.Install(nodes.Get(2), nodes.Get(0));

    p2p.EnableAsciiAll(ascii.CreateFileStream("trace.tr"));
    p2p.EnablePcapAll("oblivious", true);

    Ipv6AddressHelper addressHelper;
    addressHelper.SetBase(Ipv6Address("2001:1::"), Ipv6Prefix(64));
    auto interfaces1 = addressHelper.Assign(devices1);
    interfaces1.SetForwarding(1, true);
    interfaces1.SetDefaultRouteInAllNodes(1);

    addressHelper.SetBase(Ipv6Address("2001:2::"), Ipv6Prefix(64));
    auto interfaces2 = addressHelper.Assign(devices2);
    interfaces2.SetForwarding(0, true);
    interfaces2.SetDefaultRouteInAllNodes(0);

    auto routingProtocol = nodes.Get(0)->GetObject<Ipv6>()->GetRoutingProtocol();
    NS_LOG_INFO("Heyo");
    routingProtocol->PrintRoutingTable(ascii.CreateFileStream("routing_table.tr"));
    NS_LOG_INFO("Done");

    ApplicationHelper appHelper(ObliviousApp::GetTypeId());
    ApplicationContainer apps = appHelper.Install(nodes);

    auto node = nodes.Get(0);
    stackHelper.PrintRoutingTable(node);
    apps.Get(0)->SetAttribute("Peer", AddressValue(Ipv6Address("2001:2::200:ff:fe00:4")));
    apps.Get(1)->SetAttribute("Peer", AddressValue(Ipv6Address("2001:2::200:ff:fe00:4")));

    apps.Start(Seconds(2.0));
    apps.Stop(Seconds(20.0));

    Simulator::Run();
    Simulator::Destroy();
    return 0;
}
