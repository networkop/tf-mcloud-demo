
%EOS-STARTUP-CONFIG-START%
switchport default mode routed
!
ip name-server 1.1.1.1
!
hostname ${ hostname } 
username ${ username } secret ${ password }
aaa root secret ${ password }
!
management api http-commands
 no shut
!
interface loopback 0
 ip address ${ publicIP }/32
!
%EOS-STARTUP-CONFIG-END%