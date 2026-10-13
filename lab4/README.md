# ОТЧЁТ ПО ЛАБОРАТОРНОЙ РАБОТЕ № 2

Министерство науки и высшего образования Российской Федерации
федеральное государственное автономное образовательное учреждение высшего образования
«Национальный исследовательский университет ИТМО»

*Факультет программной инженерии и компьютерной техники*

**По дисциплине:** Администрирование систем и сетей  
**Тема:** «Создание взаимосвязанной IP-сети»  

**Желаемая оценка:** 3

**Выполнил:**  
Студент гр. P3414  
Козьяков А. Д.

**Проверил:**
Афанасьев Д.Б.

Санкт-Петербург — 2026 г.

---

## Оглавление

---

##  Основы Ethernet и конфигурирование VLAN

### Топология

### Выполение 

0) Предварительная настройка

Поднятие моста:

```bash
sudo ip link add s1 type bridge

sudo ip link set s1 up

sudo ip link set dev s1 type bridge vlan_filtering 1
```

Настройка топологии:

```bash
for p in p-r1 p-r2a p-r2b p-r3; do
    sudo bridge vlan del dev "$p" vid 1
done

sudo bridge vlan add dev p-r1  vid 10 pvid untagged
sudo bridge vlan add dev p-r2a vid 10 pvid untagged

sudo bridge vlan add dev p-r2b vid 20 pvid untagged
sudo bridge vlan add dev p-r3  vid 20 pvid untagged
```

Пример пинга

```bash
docker exec clab-lab4-r1 ping -I 10.1.2.1 -c 3 10.1.2.2
PING 10.1.2.2 (10.1.2.2) from 10.1.2.1: 56 data bytes
64 bytes from 10.1.2.2: seq=0 ttl=64 time=0.068 ms
64 bytes from 10.1.2.2: seq=1 ttl=64 time=0.101 ms
64 bytes from 10.1.2.2: seq=2 ttl=64 time=0.106 ms

--- 10.1.2.2 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.068/0.091/0.106 ms
```

```bash
bridge vlan show
port              vlan-id  
virbr0            1 PVID Egress Untagged
br-5542d821a04f   1 PVID Egress Untagged
docker0           1 PVID Egress Untagged
br-ce16db5ca905   1 PVID Egress Untagged
br-ef1a1aa7de6a   1 PVID Egress Untagged
s1                1 PVID Egress Untagged
br-db61b16eb559   1 PVID Egress Untagged
veth27f3b70       1 PVID Egress Untagged
veth7bb8288       1 PVID Egress Untagged
veth227c55c       1 PVID Egress Untagged
p-r1              10 PVID Egress Untagged
p-r2a             10 PVID Egress Untagged
p-r2b             20 PVID Egress Untagged
p-r3              20 PVID Egress Untagged
```
Создание образа:

```bash
docker build --network=host -t frr-telnet:10.5.1 ./lab4/frr-telnet
```

1) Назначение ip адресов и ospf

```bash
r1# co
r1(config)# route ospf
r1(config-router)# ex
r1(config)# ex
r1# co
r1(config)# in eth1
r1(config-if)# ip a 10.1.2.1/24
r1(config-if)# ex
r1(config)# in lo
r1(config-if)# ip a 10.0.1.1/32
r1(config-if)# ex
r1(config)# in lo:0
r1(config-if)# ip a 10.1.1.1/32
r1(config-if)# ex
r1(config)# in lo:1
r1(config-if)# ip a 10.1.4.1/32
r1(config-if)# ex
r1(config)# route ospf
r1(config-router)# ospf router-id 1.1.1.1
r1(config-router)# network 10.1.2.0/24 area 0
r1(config-router)# network 10.1.1.0/24 area 0
r1(config-router)# network 10.1.4.0/24 area 0
r1(config-router)#ex
r1(config)# ex
r1# show ip ospf neighbor

Neighbor ID     Pri State           Up Time         Dead Time Address         Interface                        RXmtL RqstL DBsmL
2.2.1.1           1 Full/DR         1m19s             30.226s 10.1.2.2        eth1:10.1.2.1                        0     0     0

```

2) Создание telnet сервера на r3

Поскольку FRR не имеет telnet, необходимо его установить. Чтобы каждый раз не устанавливать telnet я собрал образ, содержащий frr и telnet

Пользователь по заданию уже есть в конфиге, но вот пример создания пользователя:

```bash
r3:/# adduser -D -G frrvty -s /usr/local/bin/frr-telnet-shell student
passwd student
Changing password for student
New password: 
Bad password: similar to username
Retype password: 
passwd: password for student changed by root
```

Узнаем ip адрес r3:

```bash
[karel@CL4P-TP NetworkAdministration]$ docker inspect clab-lab4-r3 | grep "IPAddress"
                    "IPAddress": "172.30.30.4",
```

Подключаемся по telnet

Логин дефолтного юзера: telnetuser
Пароль: Huawei@123

```bash
telnet 172.30.30.4 23
Trying 172.30.30.4...
Connected to 172.30.30.4.
Escape character is '^]'.

r3 login: student
Password: 
Welcome to Alpine!

The Alpine Wiki contains a large amount of how-to guides and general
information about administrating Alpine systems.
See <https://wiki.alpinelinux.org/>.

You can setup the system with the command: setup-alpine

You may change this message by editing /etc/motd.

% Can't open configuration file /etc/frr/vtysh.conf due to 'No such file or directory'.
Configuration file[/etc/frr/frr.conf] processing failure: 11

Hello, this is FRRouting (version 10.5.1_git).
Copyright 1996-2005 Kunihiro Ishiguro, et al.

r3# con
r3(config)# ex
r3# sh in brief 
Interface       Status  VRF             Addresses
---------       ------  ---             ---------
eth0            up      default         172.30.30.4/24
eth1            up      default         10.1.3.1/24
                                        fe80::a8c1:abff:fe2f:d248/64
lo              up      default         10.0.1.3/32

r3# 
```

3) Настройка ACL на основе необходимого трафика

Можно сделать двумя способами, через iptables или через FRR. Продемонстрирую два подхода

Через iptables (внутри r3):

```bash
iptables -A INPUT -p tcp --dport 23 -s 10.1.4.1 -j ACCEPT
iptables -A INPUT -p tcp --dport 23 -j DROP
```

проверка:

```bash
[karel@CL4P-TP NetworkAdministration]$ docker exec clab-lab4-r1 nc -zvw3 -s 10.1.4.1 10.1.3.1 23
docker exec clab-lab4-r1 nc -zvw3 -s 10.1.1.1 10.1.3.1 23
10.1.3.1 (10.1.3.1:23) open
nc: 10.1.3.1 (10.1.3.1:23): Operation timed out
```

через FRR:

```bash
r3# con
r3(config)# ac
  access-list  Access list entry
r3(config)# access-list 
  ACCESSLIST4_NAME  Access list name
r3(config)# access-list LAB   
  deny    Specify packets to reject
  permit  Specify packets to forward
  remark  Access list entry comment
  seq     Sequence number of an entry
r3(config)# access-list LAB permit 
  A.B.C.D    Address to match
  A.B.C.D/M  Prefix to match. e.g. 10.0.0.0/8
  any        Match any IPv4
  host       A single host address
  ip         IPv4 address
r3(config)# access-list LAB permit 10.1.4.1/32
r3(config)# access-list LAB deny any          
r3(config)# line vty    
r3(config-line)# access-class 
  WORD  IP access list
r3(config-line)# access-class LAB
r3(config-line)# end
r3# show ip a
access-list          as-path-access-list  
r3# show ip access-list LAB
ZEBRA:
Zebra IP access list LAB
    seq 5 permit 10.1.4.1/32
    seq 10 deny   any
OSPF:
Zebra IP access list LAB
    seq 5 permit 10.1.4.1/32
    seq 10 deny   any
r3# exit
```

Также необходимо установить пароль и открыть zebra_options для всех ip, потому что мы никак не можем напрямую подключиться из требуемого ip адреса к telnet. 

Проверка:

```bash
docker exec -it clab-lab4-r1 nc -v -s 10.1.4.1 10.1.3.1 2601
10.1.3.1 (10.1.3.1:2601) open

Hello, this is FRRouting (version 10.5.1_git).
Copyright 1996-2005 Kunihiro Ishiguro, et al.


User Access Verification

������"��Password: LabVTY123

r3> ^Cpunt!
[karel@CL4P-TP NetworkAdministration]$ docker exec -it clab-lab4-r1 nc -v -w 5 -s 10.1.1.1 10.1.3.1 2601
10.1.3.1 (10.1.3.1:2601) open
[karel@CL4P-TP NetworkAdministration]$ docker exec -it clab-lab4-r1 nc -v -s 10.1.1.1 10.1.3.1 2601
10.1.3.1 (10.1.3.1:2601) open
^Cpunt!

```
В первом случае мы получили ответ от vtysh, во втором я ограничил время ответа и ответа не получил, в третьем случае я неограничивал время ответа и после длинного ожидания прервал выполнение, значит, соединение по запрещенному адресу не создается.




999) Очистка ОС от лабы

```bash
sudo tc filter del dev eth210 ingress pref 10 2>/dev/null || true

sudo tc qdisc del dev eth210 clsact 2>/dev/null || true

sudo ip link del dev s1.10 2>/dev/null || true

sudo containerlab destroy --topo lab3/topology.clab.yml --cleanup

for br in s1 s2 s3 s4 s5; do
    if ip link show dev "$br" >/dev/null 2>&1; then
        sudo ip link set dev "$br" down
        sudo ip link del dev "$br"
    fi
done
```
