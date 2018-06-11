!
ip security
   ike policy IKE-PROPOSAL-AES-256-CBC-GR20
      ike-lifetime 24
      encryption aes256
      dh-group 20
      local-id ${ publicIP }
   !
   sa policy IPSEC-POLICY-AES-256-CBC-GR20
      pfs dh-group 20
   !
   profile IPSEC-PROFILE-AES-256-CBC-GR20
      ike-policy IKE-PROPOSAL-AES-256-CBC-GR20 
      sa-policy IPSEC-POLICY-AES-256-CBC-GR20 
      connection start
      shared-key ${ ipsec_psk }
!
${join("\n",formatlist("ip route %s %s tag 100\n!", split("!", local_subnets), static_nh))}
!
interface Tunnel0
   mtu 1428
   ip address ${ local_tunnel_ip }/24
   tunnel mode ipsec
   tunnel source ${ tunnel_source }
   tunnel mss ceiling 1380
   tunnel ipsec profile IPSEC-PROFILE-AES-256-CBC-GR20
! 
route-map PL-STATIC permit 10
   match tag 100
!
router bgp ${ local_asn }
   neighbor ${ peer_tunnel_ip } remote-as ${ peer_asn }
   redistribute static route-map PL-STATIC
!