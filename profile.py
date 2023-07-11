import geni.portal as portal
import geni.rspec.pg as pg
import geni.rspec.igext as IG
   
pc = portal.Context()

pc.defineParameter( "nk8s", 
                   "Number of Kubernetes nodes (2 or more)", 
                   portal.ParameterType.INTEGER, 2 )
pc.defineParameter( "nhpc", 
                   "Number of HPC nodes (2 or more)", 
                   portal.ParameterType.INTEGER, 2 )
pc.defineParameter( "corecount", 
                   "Number of cores in each node.  NB: Make certain your requested cluster can supply this quantity.", 
                   portal.ParameterType.INTEGER, 4 )
pc.defineParameter( "ramsize", "MB of RAM in each node.  NB: Make certain your requested cluster can supply this quantity.", 
                   portal.ParameterType.INTEGER, 8192 )
params = pc.bindParameters()
request = pc.makeRequestRSpec()

tourDescription = \
"""
This profile is based on Ubuntu 20.04
"""

#
# Setup the Tour info with the above description and instructions.
#  
tour = IG.Tour()
tour.Description(IG.Tour.TEXT,tourDescription)
request.addTour(tour)

prefixForIP = "192.168.1."
link = request.LAN("lan")

num_nodes = params.nk8s + params.nhpc + 2
k8s_count = 1;
compute_count = 1;
for i in range(num_nodes):
  nodename = ""
  if i == 0:
    nodename = "cas"
  elif i == 1:
    nodename = "master"
  elif i >= 2 and i <= params.nk8s:
    nodename = "k8s-" + str(k8s_count)
    k8s_count += 1
  else:
    nodename = "compute-" + str(compute_count)
    compute_count += 1
     
  node = request.XenVM(nodename)
  node.cores = params.corecount
  node.ram = params.ramsize
  bs_landing = node.Blockstore("bs_" + nodename, "/image")
  bs_landing.size = "500GB"
  node.routable_control_ip = "true" 
  node.disk_image = "urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD"
  iface = node.addInterface("if" + str(i))
  iface.component_id = "eth1"
  iface.addAddress(pg.IPv4Address(prefixForIP + str(i + 1), "255.255.255.0"))
  link.addInterface(iface)
  
  # install Docker
  #node.addService(pg.Execute(shell="sh", command="sudo bash /local/repository/install_docker.sh"))
  # install Kubernetes
  #node.addService(pg.Execute(shell="sh", command="sudo bash /local/repository/install_kubernetes.sh"))
  #node.addService(pg.Execute(shell="sh", command="sudo swapoff -a"))
  
  if i == 0:
    # install Puppet
    node.addService(pg.Execute(shell="sh", command="sudo bash /local/repository/install_puppet_ubuntu.sh server " + str(num_nodes)))
  else:
    node.addService(pg.Execute(shell="sh", command="sudo bash /local/repository/install_puppet_ubuntu.sh " + nodename))

pc.printRequestRSpec(request)
