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

## Адресация и маршрутизация IPv4

### Топология

### Выполение 

0) Поднятие сети и подключение к конкретному оборудованию

```bash
sudo containerlab deploy --topo *файл с топологией*
```

```bash
docker exec -it [название контейнера] vtysh
```

1) Имя хоста можно изменить с помощью команды

```bash
hostname HOSTNAME
```

Поскольку далее я буду пользоваться именами по умолчанию, для примера изменю имя хоста и верну его:

```bash
r1# configure 
r1(config)# hostname SOMEONE
SOMEONE(config)# exit
```

2) IP-адрес текущего интерфейса и таблица маршрутизации

```bash
r1# show interface brief 
Interface       Status  VRF             Addresses
---------       ------  ---             ---------
eth0            up      default         172.30.30.3/24
eth1            up      default         fe80::a8c1:abff:fe5c:4144/64
eth2            up      default         fe80::a8c1:abff:fead:8dc/64
lo              up      default         
```

Таблица маршрутизации r1:

```bash
r1# show ip route
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

IPv4 unicast VRF default:
K>* 0.0.0.0/0 [0/0] via 172.30.30.1, eth0, weight 1, 00:27:35
C>* 172.30.30.0/24 is directly connected, eth0, weight 1, 00:27:35
L>* 172.30.30.3/32 is directly connected, eth0, weight 1, 00:27:35

```
3) Настройка IP-адреса физических интерфейсов

Поскольку в frr можно указывать ip адреса в конфигурационном файле, а ip адреса назначаются аналогично, то для удобства буду настраивать их там, но вот пример настройки вручную:

```bash
r1# configure 
r1(config)# interface eth1
r1(config-if)# ip address 10.0.12.1/24
r1(config-if)# no shutdown 
rr1(config-if)# exit
r1(config)# interface eth2
r1(config-if)# ip address 10.0.13.1/24
r1(config-if)# no shutdown 
r1(config-if)# exit
r1(config)# exit
r1# show interface brief 
Interface       Status  VRF             Addresses
---------       ------  ---             ---------
eth0            up      default         172.30.30.3/24
eth1            up      default         10.0.12.1/24
                                        fe80::a8c1:abff:fe5c:4144/64
eth2            up      default         10.0.13.1/24
                                        fe80::a8c1:abff:fead:8dc/64
lo              up      default         
```

Проверим подключение с помощью ping:

```bash
r1:/# ping -c 4 10.0.12.2
PING 10.0.12.2 (10.0.12.2): 56 data bytes
64 bytes from 10.0.12.2: seq=0 ttl=64 time=0.108 ms
64 bytes from 10.0.12.2: seq=1 ttl=64 time=0.057 ms
64 bytes from 10.0.12.2: seq=2 ttl=64 time=0.084 ms
64 bytes from 10.0.12.2: seq=3 ttl=64 time=0.084 ms

--- 10.0.12.2 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.057/0.083/0.108 ms
```

Таблица маршрутизации r1:

```bash
r1# show ip ro    
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

IPv4 unicast VRF default:
K>* 0.0.0.0/0 [0/0] via 172.30.30.1, eth0, weight 1, 00:08:14
C>* 10.0.12.0/24 is directly connected, eth1, weight 1, 00:08:13
L>* 10.0.12.1/32 is directly connected, eth1, weight 1, 00:08:13
C>* 10.0.13.0/24 is directly connected, eth2, weight 1, 00:08:13
L>* 10.0.13.2/32 is directly connected, eth2, weight 1, 00:08:13
C>* 10.0.15.0/24 is directly connected, eth3, weight 1, 00:08:13
L>* 10.0.15.2/32 is directly connected, eth3, weight 1, 00:08:13
C>* 172.30.30.0/24 is directly connected, eth0, weight 1, 00:08:13
L * 172.30.30.6/32 is directly connected, eth0, weight 1, 00:08:13
L>* 172.30.30.6/32 is directly connected, eth0, weight 1, 00:08:14
```

4) Создание loopback интерфейса

```bash
r1# configure   
r1(config)# interface lo
r1(config-if)# ip address 10.0.1.1/32
r1(config-if)# exit
r1(config)# exit
r1# show interface brief 
Interface       Status  VRF             Addresses
---------       ------  ---             ---------
eth0            up      default         172.30.30.6/24
eth1            up      default         10.0.12.1/24
                                        fe80::a8c1:abff:fe1f:4bdf/64
eth2            up      default         10.0.13.2/24
                                        fe80::a8c1:abff:fe05:c359/64
eth3            up      default         10.0.15.2/24
                                        fe80::a8c1:abff:fe8c:5475/64
lo              up      default         10.0.1.1/32

```

Проверка связи между двумя loopback интерфейсами

```bash
r1:/# ping -c 4 -I 10.0.1.1 10.0.1.2
PING 10.0.1.2 (10.0.1.2) from 10.0.1.1: 56 data bytes

--- 10.0.1.2 ping statistics ---
4 packets transmitted, 0 packets received, 100% packet loss
```

5) Настройка статических маршрутов

```bash
r1# configure 
r1(config)# ip route 10.0.1.2/32 10.0.12.2   
r1(config)# ip route 10.0.1.3/32 10.0.13.1
r1(config)# exit
r1# show ip ro
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

IPv4 unicast VRF default:
K>* 0.0.0.0/0 [0/0] via 172.30.30.1, eth0, weight 1, 00:13:44
L * 10.0.1.1/32 is directly connected, lo, weight 1, 00:13:43
C>* 10.0.1.1/32 is directly connected, lo, weight 1, 00:13:43
S>* 10.0.1.2/32 [1/0] via 10.0.12.2, eth1, weight 1, 00:00:18
S>* 10.0.1.3/32 [1/0] via 10.0.13.1, eth2, weight 1, 00:00:08
C>* 10.0.12.0/24 is directly connected, eth1, weight 1, 00:13:43
L>* 10.0.12.1/32 is directly connected, eth1, weight 1, 00:13:43
C>* 10.0.13.0/24 is directly connected, eth2, weight 1, 00:13:43
L>* 10.0.13.2/32 is directly connected, eth2, weight 1, 00:13:43
C>* 10.0.15.0/24 is directly connected, eth3, weight 1, 00:13:43
L>* 10.0.15.2/32 is directly connected, eth3, weight 1, 00:13:43
C>* 172.30.30.0/24 is directly connected, eth0, weight 1, 00:13:43
L * 172.30.30.5/32 is directly connected, eth0, weight 1, 00:13:43
L>* 172.30.30.5/32 is directly connected, eth0, weight 1, 00:13:44
```

Возможность установления связи


```bash
r1:/# ping -c 4 -I 10.0.1.1 10.0.1.2
PING 10.0.1.2 (10.0.1.2) from 10.0.1.1: 56 data bytes

--- 10.0.1.2 ping statistics ---
4 packets transmitted, 0 packets received, 100% packet loss
```

Добавление обратного маршрута от r2:

```bash
r2# configure 
r2(config)# ip route 10.0.1.1/32 10.0.12.1
```

Проверка доступности:

```bash
r1:/# ping -c 4 -I 10.0.1.1 10.0.1.2
PING 10.0.1.2 (10.0.1.2) from 10.0.1.1: 56 data bytes
64 bytes from 10.0.1.2: seq=0 ttl=64 time=0.140 ms
64 bytes from 10.0.1.2: seq=1 ttl=64 time=0.071 ms
64 bytes from 10.0.1.2: seq=2 ttl=64 time=0.071 ms
64 bytes from 10.0.1.2: seq=3 ttl=64 time=0.065 ms

--- 10.0.1.2 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.065/0.086/0.140 ms
```

Аналогично устанавливаем маршруты для других рутеров.

Пример пинга от r4 до r5:

```bash
r4:/# ping -c 4 -I 10.0.1.4 10.0.1.5 
PING 10.0.1.5 (10.0.1.5) from 10.0.1.4: 56 data bytes
64 bytes from 10.0.1.5: seq=0 ttl=64 time=0.100 ms
64 bytes from 10.0.1.5: seq=1 ttl=64 time=0.051 ms
64 bytes from 10.0.1.5: seq=2 ttl=64 time=0.113 ms
64 bytes from 10.0.1.5: seq=3 ttl=64 time=0.114 ms
```

Добавление резервного маршрута:

```bash
r1(config)# ip route 10.0.1.2/32 10.0.13.3 100
```

Проверка таблицы маршрутизации:

```bash
r1# show ip ro
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

IPv4 unicast VRF default:
K>* 0.0.0.0/0 [0/0] via 172.30.30.1, eth0, weight 1, 00:00:14
L * 10.0.1.1/32 is directly connected, lo, weight 1, 00:00:13
C>* 10.0.1.1/32 is directly connected, lo, weight 1, 00:00:13
S>* 10.0.1.2/32 [1/0] via 10.0.12.2, eth1, weight 1, 00:00:13
S   10.0.1.2/32 [100/0] via 10.0.13.3, eth2, weight 1, 00:00:13
S>* 10.0.1.3/32 [1/0] via 10.0.13.1, eth2, weight 1, 00:00:13
S>* 10.0.1.5/32 [1/0] via 10.0.15.1, eth3, weight 1, 00:00:13
C>* 10.0.12.0/24 is directly connected, eth1, weight 1, 00:00:13
L>* 10.0.12.1/32 is directly connected, eth1, weight 1, 00:00:13
C>* 10.0.13.0/24 is directly connected, eth2, weight 1, 00:00:13
L>* 10.0.13.2/32 is directly connected, eth2, weight 1, 00:00:13
C>* 10.0.15.0/24 is directly connected, eth3, weight 1, 00:00:13
L>* 10.0.15.2/32 is directly connected, eth3, weight 1, 00:00:13
C>* 172.30.30.0/24 is directly connected, eth0, weight 1, 00:00:13
L * 172.30.30.4/32 is directly connected, eth0, weight 1, 00:00:13
L>* 172.30.30.4/32 is directly connected, eth0, weight 1, 00:00:14
```

Таблица маршрутизации после выключения интерфейса, r1:

```bash
r1# sh ip ro
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

IPv4 unicast VRF default:
K>* 0.0.0.0/0 [0/0] via 172.30.30.1, eth0, weight 1, 00:01:10
L * 10.0.1.1/32 is directly connected, lo, weight 1, 00:01:10
C>* 10.0.1.1/32 is directly connected, lo, weight 1, 00:01:10
S   10.0.1.2/32 [1/0] via 10.0.12.2, eth1 inactive, weight 1, 00:01:09
S>* 10.0.1.2/32 [100/0] via 10.0.13.1, eth2, weight 1, 00:01:09
S>* 10.0.1.3/32 [1/0] via 10.0.13.1, eth2, weight 1, 00:01:09
S>* 10.0.1.5/32 [1/0] via 10.0.15.1, eth3, weight 1, 00:01:09
C>* 10.0.13.0/24 is directly connected, eth2, weight 1, 00:01:10
L>* 10.0.13.2/32 is directly connected, eth2, weight 1, 00:01:10
C>* 10.0.15.0/24 is directly connected, eth3, weight 1, 00:01:10
L>* 10.0.15.2/32 is directly connected, eth3, weight 1, 00:01:10
C>* 172.30.30.0/24 is directly connected, eth0, weight 1, 00:01:10
L * 172.30.30.7/32 is directly connected, eth0, weight 1, 00:01:10
L>* 172.30.30.7/32 is directly connected, eth0, weight 1, 00:01:10
```

r2:

```bash
r2# sh ip ro
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

IPv4 unicast VRF default:
K>* 0.0.0.0/0 [0/0] via 172.30.30.1, eth0, weight 1, 00:02:15
S   10.0.1.1/32 [1/0] via 10.0.12.1, eth1 inactive, weight 1, 00:02:14
S>* 10.0.1.1/32 [100/0] via 10.0.23.2, eth2, weight 1, 00:02:14
L * 10.0.1.2/32 is directly connected, lo, weight 1, 00:02:15
C>* 10.0.1.2/32 is directly connected, lo, weight 1, 00:02:15
S>* 10.0.1.3/32 [1/0] via 10.0.23.2, eth2, weight 1, 00:02:14
S>* 10.0.1.4/32 [1/0] via 10.0.24.2, eth3, weight 1, 00:02:14
C>* 10.0.23.0/24 is directly connected, eth2, weight 1, 00:02:15
L>* 10.0.23.1/32 is directly connected, eth2, weight 1, 00:02:15
C>* 10.0.24.0/24 is directly connected, eth3, weight 1, 00:02:15
L>* 10.0.24.1/32 is directly connected, eth3, weight 1, 00:02:15
C>* 172.30.30.0/24 is directly connected, eth0, weight 1, 00:02:15
L * 172.30.30.3/32 is directly connected, eth0, weight 1, 00:02:15
L>* 172.30.30.3/32 is directly connected, eth0, weight 1, 00:02:15
```

Пинг:

```bash
r1:/# ping -c 4 -I 10.0.1.1 10.0.1.2
PING 10.0.1.2 (10.0.1.2) from 10.0.1.1: 56 data bytes
64 bytes from 10.0.1.2: seq=0 ttl=63 time=0.194 ms
64 bytes from 10.0.1.2: seq=1 ttl=63 time=0.092 ms
64 bytes from 10.0.1.2: seq=2 ttl=63 time=0.074 ms
64 bytes from 10.0.1.2: seq=3 ttl=63 time=0.091 ms

--- 10.0.1.2 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.074/0.112/0.194 ms
```

Трассировка маршрута:

```bash
r1:/# traceroute -s 10.0.1.1 10.0.1.2
traceroute to 10.0.1.2 (10.0.1.2) from 10.0.1.1, 30 hops max, 46 byte packets
 1  10.0.13.1 (10.0.13.1)  0.005 ms  0.007 ms  0.005 ms
 2  10.0.1.2 (10.0.1.2)  0.005 ms  0.007 ms  0.005 ms
```

7) Настройка маршрутов по умолчанию

Пример для r1, удаление старых маршрутов:

```bash
r1# configure               
r1(config)# interface eth1
r1(config-if)# no shutdown
r1(config-if)# quit
r1(config)# no ip route 10.0.1.2/32 10.0.12.2 eth1
r1(config)# no ip route 10.0.1.2/32 10.0.13.1 100
r1(config)# exit
r1# sh ip ro
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

IPv4 unicast VRF default:
K>* 0.0.0.0/0 [0/0] via 172.30.30.1, eth0, weight 1, 00:17:33
L * 10.0.1.1/32 is directly connected, lo, weight 1, 00:17:33
C>* 10.0.1.1/32 is directly connected, lo, weight 1, 00:17:33
S>* 10.0.1.3/32 [1/0] via 10.0.13.1, eth2, weight 1, 00:17:32
S>* 10.0.1.5/32 [1/0] via 10.0.15.1, eth3, weight 1, 00:17:32
C>* 10.0.13.0/24 is directly connected, eth2, weight 1, 00:17:33
L>* 10.0.13.2/32 is directly connected, eth2, weight 1, 00:17:33
C>* 10.0.15.0/24 is directly connected, eth3, weight 1, 00:17:33
L>* 10.0.15.2/32 is directly connected, eth3, weight 1, 00:17:33
C>* 172.30.30.0/24 is directly connected, eth0, weight 1, 00:17:33
L * 172.30.30.7/32 is directly connected, eth0, weight 1, 00:17:33
L>* 172.30.30.7/32 is directly connected, eth0, weight 1, 00:17:33
```

Назначение маршрута по умолчанию:
```bash
r1# configure
r1(config)# ip route 0.0.0.0/0 10.0.12.2
r1(config)# end
r1# sh ip ro
Codes: K - kernel route, C - connected, L - local, S - static,
       R - RIP, O - OSPF, I - IS-IS, B - BGP, E - EIGRP, N - NHRP,
       T - Table, v - VNC, V - VNC-Direct, A - Babel, F - PBR,
       f - OpenFabric, t - Table-Direct,
       > - selected route, * - FIB route, q - queued, r - rejected, b - backup
       t - trapped, o - offload failure

IPv4 unicast VRF default:
S   0.0.0.0/0 [1/0] via 10.0.12.2 inactive, weight 1, 00:00:13
K>* 0.0.0.0/0 [0/0] via 172.30.30.1, eth0, weight 1, 00:13:24
L * 10.0.1.1/32 is directly connected, lo, weight 1, 00:13:24
C>* 10.0.1.1/32 is directly connected, lo, weight 1, 00:13:24
S>* 10.0.1.3/32 [1/0] via 10.0.13.1, eth2, weight 1, 00:13:23
S>* 10.0.1.5/32 [1/0] via 10.0.15.1, eth3, weight 1, 00:13:23
C>* 10.0.13.0/24 is directly connected, eth2, weight 1, 00:13:24
L>* 10.0.13.2/32 is directly connected, eth2, weight 1, 00:13:24
C>* 10.0.15.0/24 is directly connected, eth3, weight 1, 00:13:24
L>* 10.0.15.2/32 is directly connected, eth3, weight 1, 00:13:24
C>* 172.30.30.0/24 is directly connected, eth0, weight 1, 00:13:24
L * 172.30.30.7/32 is directly connected, eth0, weight 1, 00:13:24
L>* 172.30.30.7/32 is directly connected, eth0, weight 1, 00:13:24
```

Проверка связи между loopback r1 и r2:

```bash
r1:/# ping -c 4 -I 10.0.1.1 10.0.1.2
PING 10.0.1.2 (10.0.1.2) from 10.0.1.1: 56 data bytes
64 bytes from 10.0.1.2: seq=0 ttl=64 time=0.077 ms
64 bytes from 10.0.1.2: seq=1 ttl=64 time=0.094 ms
64 bytes from 10.0.1.2: seq=2 ttl=64 time=0.050 ms
64 bytes from 10.0.1.2: seq=3 ttl=64 time=0.080 ms

--- 10.0.1.2 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 0.050/0.075/0.094 ms
```
