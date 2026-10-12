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

```bash
sudo ip link add s1 type bridge stp_state 1
sudo ip link add s2 type bridge stp_state 1
sudo ip link add s3 type bridge stp_state 1
sudo ip link add s4 type bridge stp_state 1
sudo ip link add s5 type bridge stp_state 1

sudo ip link set s1 up
sudo ip link set s2 up
sudo ip link set s3 up
sudo ip link set s4 up
sudo ip link set s5 up
```

Запустить лабу:

```bash
sudo containerlab deploy --topo lab3/topology.clab.yml
```

1) Базовая настройка свичей

Поскольку мы сами создаем свичи, они уже названы правильно и не имеют лишних портов

При этом название поменять можно командой:
(Обязательно надо сначала выключить)

```bash
sudo ip link set dev s1 down
sudo ip link set dev s1 name s11
ip link show
......
71: s11: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 9500 qdisc noqueue state DOWN mode DEFAULT group default qlen 1000
    link/ether 06:5e:fb:d6:2e:2f brd ff:ff:ff:ff:ff:ff
......
```
Подключим лишний интерфейс, для этого сначала создадим новое устройство:

```bash
sudo ip link add veth0 type veth peer name veth1
ip link show veth0
98: veth0@veth1: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ether 26:ef:4d:4b:fa:a7 brd ff:ff:ff:ff:ff:ff

```

```bash
ip link show master s1
.....
98: veth0@veth1: <BROADCAST,MULTICAST,M-DOWN> mtu 1500 qdisc noop master s1 state DOWN mode DEFAULT group default ql
en 1000
    link/ether 26:ef:4d:4b:fa:a7 brd ff:ff:ff:ff:ff:ff
```

Удаляем лишний интерфейс:

```bash
sudo ip link set dev veth0 nomaster
```

2) Настройка IP-адресов устройств

Для r6, r7, r8:

```bash
r8# con
r8(config)# interface eth81
r8(config-if)# ip address 192.168.8.10/24
r8(config-if)# no shutdown
r8(config-if)# exit
r8(config)# exit
r8# show interface brief 
Interface       Status  VRF             Addresses
---------       ------  ---             ---------
eth0            up      default         172.30.30.2/24
eth81           up      default         192.168.8.10/24
                                        fe80::a8c1:abff:fef1:9429/64
lo              up      default         10.0.1.8/32
```

Для s1...s5:

```bash
sudo ip addr add 192.168.1.10/24 dev s1
sudo ip addr add 192.168.2.10/24 dev s2
sudo ip addr add 192.168.3.10/24 dev s3
sudo ip addr add 192.168.4.10/24 dev s4
sudo ip addr add 192.168.5.10/24 dev s5
```

3) Создание VLAN

Разрешаем vlan фильтрацию:

```bash
sudo ip link set dev s1 type bridge vlan_filtering 1
sudo ip link set dev s2 type bridge vlan_filtering 1
sudo ip link set dev s3 type bridge vlan_filtering 1
sudo ip link set dev s4 type bridge vlan_filtering 1
sudo ip link set dev s5 type bridge vlan_filtering 1
```

Назначаем vlan интерфейсам

```bash
# s1 <-> s2
sudo bridge vlan add dev eth12 vid 6
sudo bridge vlan add dev eth21 vid 6

# s2 <-> s3
sudo bridge vlan add dev eth23 vid 6
sudo bridge vlan add dev eth32 vid 6

# s1 <-> s5
sudo bridge vlan add dev eth15 vid 6
sudo bridge vlan add dev eth51 vid 6

# s2 -> r6
sudo bridge vlan add dev eth26 vid 6 pvid untagged

# s3 -> r7
sudo bridge vlan add dev eth37 vid 6 pvid untagged

# s5 -> r10
sudo bridge vlan add dev eth510 vid 6 pvid untagged

# s1 <-> s3
sudo bridge vlan add dev eth13 vid 6
sudo bridge vlan add dev eth31 vid 6

# s1 <-> s4
sudo bridge vlan add dev eth14 vid 8
sudo bridge vlan add dev eth41 vid 8
sudo bridge vlan add dev eth18 vid 8 pvid untagged
sudo bridge vlan add dev eth49 vid 8 pvid untagged
```

Проверка

```bash
sudo bridge vlan show
port              vlan-id  
virbr0            1 PVID Egress Untagged
docker0           1 PVID Egress Untagged
br-ce16db5ca905   1 PVID Egress Untagged
br-ef1a1aa7de6a   1 PVID Egress Untagged
br-5542d821a04f   1 PVID Egress Untagged
br-10ffe971a450   1 PVID Egress Untagged
veth55c1d00       1 PVID Egress Untagged
veth7baba0e       1 PVID Egress Untagged
vethc0f2e4d       1 PVID Egress Untagged
vethdf9ee3c       1 PVID Egress Untagged
eth21             6
eth12             6
eth31             6
eth13             6
eth41             8
eth14             8
eth51             6
eth15             6
eth32             6
eth23             6
eth26             6 PVID Egress Untagged
eth37             6 PVID Egress Untagged
eth18             8 PVID Egress Untagged
eth49             8 PVID Egress Untagged
eth510            6 PVID Egress Untagged
```

Пример ping:

```bash
docker exec clab-lab3-r6 ping -c 3 192.168.6.11
PING 192.168.6.11 (192.168.6.11): 56 data bytes
64 bytes from 192.168.6.11: seq=0 ttl=64 time=0.086 ms
64 bytes from 192.168.6.11: seq=1 ttl=64 time=0.123 ms
64 bytes from 192.168.6.11: seq=2 ttl=64 time=0.093 ms
```

```bash
docker exec clab-lab3-r8 ping -c 3 192.168.8.11
PING 192.168.8.11 (192.168.8.11): 56 data bytes
64 bytes from 192.168.8.11: seq=0 ttl=64 time=0.092 ms
64 bytes from 192.168.8.11: seq=1 ttl=64 time=0.134 ms
64 bytes from 192.168.8.11: seq=2 ttl=64 time=0.135 ms

--- 192.168.8.11 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.092/0.120/0.135 ms
```

4) Конфигурация vlan на основе MAC-адресов

Добавление новой vlan

```bash
sudo bridge vlan add dev eth21 vid 10
sudo bridge vlan add dev eth12 vid 10
sudo bridge vlan add dev eth210 vid 10 untagged
```

Создание нового интерфейса на s1:

```bash
sudo bridge vlan add dev s1 vid 10 self
sudo ip link add link s1 name s1.10 type vlan id 10
sudo ip addr add 192.168.10.1/24 dev s1.10
sudo ip link set dev s1.10 up
```

Настройка MAC

```bash
sudo tc qdisc add dev eth210 clsact 2>/dev/null || true
sudo tc filter add dev eth210 ingress pref 10 protocol all flower \
    src_mac a0:08:6f:e1:0c:46 \
    action vlan push id 10 protocol 802.1Q
```

Проверка :

```bash
docker exec clab-lab3-r11 ping -c 3 192.168.10.1
PING 192.168.10.1 (192.168.10.1): 56 data bytes
64 bytes from 192.168.10.1: seq=0 ttl=64 time=0.117 ms
64 bytes from 192.168.10.1: seq=1 ttl=64 time=0.096 ms
64 bytes from 192.168.10.1: seq=2 ttl=64 time=0.135 ms

--- 192.168.10.1 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.096/0.116/0.135 ms

sudo tc -s filter show dev eth210 ingress
filter protocol all pref 10 flower chain 0 
filter protocol all pref 10 flower chain 0 handle 0x1 
  src_mac a0:08:6f:e1:0c:46
  not_in_hw
        action order 1: vlan  push id 10 protocol 802.1Q priority 0 pipe
         index 1 ref 1 bind 1 installed 490 sec used 1 sec firstused 443 sec
        Action statistics:
        Sent 392 bytes 8 pkt (dropped 0, overlimits 0 requeues 0) 
        backlog 0b 0p requeues 0
```

5) Вывод информации о конфигурации

```bash
sudo bridge vlan show
port              vlan-id  
virbr0            1 PVID Egress Untagged
docker0           1 PVID Egress Untagged
br-ce16db5ca905   1 PVID Egress Untagged
br-ef1a1aa7de6a   1 PVID Egress Untagged
br-5542d821a04f   1 PVID Egress Untagged
s1                1 PVID Egress Untagged
                  10
s2                1 PVID Egress Untagged
s3                1 PVID Egress Untagged
s4                1 PVID Egress Untagged
s5                1 PVID Egress Untagged
br-10ffe971a450   1 PVID Egress Untagged
veth73217b2       1 PVID Egress Untagged
veth1dc1aeb       1 PVID Egress Untagged
veth82df9e9       1 PVID Egress Untagged
veth9ece746       1 PVID Egress Untagged
eth21             1 PVID Egress Untagged
                  6
                  10
eth12             1 PVID Egress Untagged
                  6
                  10
eth31             1 PVID Egress Untagged
                  6
eth13             1 PVID Egress Untagged
                  6
eth41             1 PVID Egress Untagged
                  8
eth14             1 PVID Egress Untagged
                  8
eth51             1 PVID Egress Untagged
                  6
eth15             1 PVID Egress Untagged
                  6
eth45             1 PVID Egress Untagged
eth54             1 PVID Egress Untagged
eth32             1 PVID Egress Untagged
                  6
eth23             1 PVID Egress Untagged
                  6
eth26             1 Egress Untagged
                  6 PVID Egress Untagged
eth37             1 Egress Untagged
                  6 PVID Egress Untagged
eth18             1 Egress Untagged
                  8 PVID Egress Untagged
eth34             1 PVID Egress Untagged
eth44             1 PVID Egress Untagged
eth49             1 Egress Untagged
                  8 PVID Egress Untagged
eth510            1 Egress Untagged
                  6 PVID Egress Untagged
eth210            1 PVID Egress Untagged
                  10 Egress Untagged
```

```bash
sudo bridge link show master s1
142: eth12@eth21: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 master s1 state forwarding priority 32 cost 2 
144: eth13@eth31: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 master s1 state forwarding priority 32 cost 2 
146: eth14@eth41: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 master s1 state forwarding priority 32 cost 2 
148: eth15@eth51: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 master s1 state forwarding priority 32 cost 2 
158: eth18@if157: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9500 master s1 state forwarding priority 32 cost 2 
[karel@CL4P-TP NetworkAdministration]$ sudo tc filter show dev eth210 ingress
filter protocol all pref 10 flower chain 0 
filter protocol all pref 10 flower chain 0 handle 0x1 
  src_mac a0:08:6f:e1:0c:46
  not_in_hw
        action order 1: vlan  push id 10 protocol 802.1Q priority 0 pipe
         index 1 ref 1 bind 1

```

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
