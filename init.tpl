%EOS-STARTUP-CONFIG-START%
switchport default mode routed
!
hostname ${ hostname }
!
ip name-server 1.1.1.1
!
aaa root secret ${ password }
!
username ${ username } privilege 15 secret ${ password }
!
!
management api http-commands
  no shutdown
!
interface Loopback0
  ip address ${ publicIP }/32
!
%EOS-STARTUP-CONFIG-END%