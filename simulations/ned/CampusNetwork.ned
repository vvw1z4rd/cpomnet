package simulations.ned;

import inet.node.inet.StandardHost;
import inet.node.ethernet.EthernetSwitch;
import inet.node.inet.Router;
import inet.networklayer.configurator.ipv4.Ipv4NetworkConfigurator;
import inet.common.scenario.ScenarioManager;
import inet.node.ethernet.Eth1G;
import inet.node.ethernet.Eth100M;

module InternetCloud
{
    gates:
        inout ethg[];

    submodules:
        internalSwitch: EthernetSwitch {
            @display("p=50,50;i=device/hub");
        }

    connections allowunconnected:
        for i=0..sizeof(ethg)-1 {
            ethg[i] <--> internalSwitch.ethg++;
        }
}

network CampusNetwork
{
    parameters:
        int numBranch1Hosts = default(15);
        int numBranch2Hosts = default(15);
        @display("bgb=1600,900");

    submodules:
        configurator: Ipv4NetworkConfigurator {
            @display("p=800,750");
        }

        scenarioManager: ScenarioManager {
            @display("p=800,50");
        }

        internet: InternetCloud {
            @display("p=800,400;i=misc/cloud");
        }

        mainRouter: Router { @display("p=850,300"); }
        backupRouter: Router { @display("p=650,300"); }

        mainSwitch: EthernetSwitch { @display("p=750,180"); }

        server1: StandardHost { @display("p=700,80;i=device/server"); }
        server2: StandardHost { @display("p=900,80;i=device/server"); }

        branch1Router: Router { @display("p=1050,500"); }
        branch1Switch: EthernetSwitch { @display("p=1250,500"); }

        branch1Host[numBranch1Hosts]: StandardHost {
            @display("p=1050,620,m,5,100,100;i=device/pc");
        }

        branch2Router: Router { @display("p=550,500"); }
        branch2Switch: EthernetSwitch { @display("p=350,500"); }

        branch2Host[numBranch2Hosts]: StandardHost {
            @display("p=140,620,m,5,100,100;i=device/pc");
        }

    connections allowunconnected:
        server1.ethg++ <--> Eth1G <--> mainSwitch.ethg++;
        server2.ethg++ <--> Eth1G <--> mainSwitch.ethg++;

        mainSwitch.ethg++ <--> Eth1G <--> mainRouter.ethg++;

        mainSwitch.ethg++ <--> Eth100M <--> backupRouter.ethg++;

        mainRouter.ethg++ <--> Eth1G <--> internet.ethg++;

        backupRouter.ethg++ <--> Eth100M <--> internet.ethg++;

        branch1Router.ethg++ <--> Eth1G <--> internet.ethg++;
        branch1Switch.ethg++ <--> Eth100M <--> branch1Router.ethg++;

        for i=0..numBranch1Hosts-1 {
            branch1Host[i].ethg++ <--> Eth100M <--> branch1Switch.ethg++;
        }

        branch2Router.ethg++ <--> Eth1G <--> internet.ethg++;
        branch2Switch.ethg++ <--> Eth100M <--> branch2Router.ethg++;

        for i=0..numBranch2Hosts-1 {
            branch2Host[i].ethg++ <--> Eth100M <--> branch2Switch.ethg++;
        }
}
