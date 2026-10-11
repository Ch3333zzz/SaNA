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

