package simulations.ned;

import inet.node.inet.StandardHost;
import inet.node.inet.Router;
import inet.node.ethernet.EthernetSwitch;
import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import inet.common.scenario.ScenarioManager;
import inet.node.ethernet.Eth1G;
import inet.node.ethernet.Eth100M;

network CampusNetworkAggregated
{
    @display("bgb=1600,900");

    submodules:

        configurator: Ipv4NetworkConfigurator {
            @display("p=80,120;i=block/cogwheel");
        }

        internet: Router {
            @display("p=760,420;i=misc/cloud");
        }

        mainSwitch: EthernetSwitch {
            @display("p=350,450;i=device/switch");
        }

        server1: StandardHost {
            @display("p=120,320;i=device/server");
        }

        server2: StandardHost {
            @display("p=120,580;i=device/server");
        }

        mainRouter: Router {
            @display("p=560,300;i=device/router");
        }

        backupRouter: Router {
            @display("p=560,520;i=device/router");
        }

        branch1Router: Router {
            @display("p=980,280;i=device/router");
        }

        branch2Router: Router {
            @display("p=980,600;i=device/router");
        }

        branch1Switch: EthernetSwitch {
            @display("p=1220,280;i=device/switch");
        }

        branch2Switch: EthernetSwitch {
            @display("p=1220,600;i=device/switch");
        }

        branch1Hosts: StandardHost {
            @display("p=1450,280;i=device/pc");
        }

        branch2Hosts: StandardHost {
            @display("p=1450,600;i=device/pc");
        }

    connections allowunconnected:

        server1.ethg++ <--> Eth1G <--> mainSwitch.ethg++;
        server2.ethg++ <--> Eth1G <--> mainSwitch.ethg++;

        mainSwitch.ethg++ <--> Eth1G <--> mainRouter.ethg++;
        mainSwitch.ethg++ <--> Eth1G <--> backupRouter.ethg++;

        mainRouter.ethg++ <--> Eth1G <--> internet.ethg++;
        backupRouter.ethg++ <--> Eth1G <--> internet.ethg++;

        internet.ethg++ <--> Eth1G <--> branch1Router.ethg++;
        internet.ethg++ <--> Eth1G <--> branch2Router.ethg++;

        branch1Router.ethg++ <--> Eth100M <--> branch1Switch.ethg++;
        branch2Router.ethg++ <--> Eth100M <--> branch2Switch.ethg++;

        branch1Switch.ethg++ <--> Eth100M <--> branch1Hosts.ethg++;
        branch2Switch.ethg++ <--> Eth100M <--> branch2Hosts.ethg++;
}