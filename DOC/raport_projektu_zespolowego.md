---
title: Special team projekt SCK
header: APB communication Exe_unit_w47 X Exe_unit_w48 
author: Vitalii Rohozhyn, Arseni Sialitski
date: January 23, 2024
---

# Komunikacja magistralą APB z układami Exe_unit_w47 oraz Exe_unit_w48

## Opis

Przedstawiony naszym zespołem badawczym projekt jest złożonym układem logicznym zawierającym w sobie dwie raniej sprojektowane jednostki wykonawcze oraz kontroller który współdziała i komunikuje z nimi za pomocą magistrali **APB** realizowanej przez tak zwany **APB_BUS**  

Zaprojektowany układ można przedstawić w postaci:

![](schemat_1.png)

## Slave-y

Jednostki wykonawcze **Exe_unit_w47** oraz **Exe_unit_w48** do prawidłowego współdziałania z slave arbiterem zostali dodatkowo opisane za pomocą modółów **APB_slave**. Każdy taki blok funkcyjny posiada wejścia i wyjścia zgodnie z interfejsem AMBA APB:


| Wejścia     |    Szerokość  |      Funkcja    |
| ----------- |:-------------:|:---------------:|
| i_PCLK      | binarne       | wejście zegara  |
| i_PRESETn   | binarne       | reset           |
| i_PADRR     | **16**-bitowe | adress slave-a  |
| i_PSEL      | binarne       | sygnał wyboru   |
| i_PENABLE   | binarne       | gotowność slave-a na odbiór danych|
| i_PWRITE    | binarne       | tryb zapisu/odczytu    |
| i_PWDATA    | **3**-bitowe  | dane do odebrania  |


| Wyjścia     |    Szerokość  |      Funkcja    |
| ----------- |:-------------:|:---------------:|
| o_PREADY    | binarne       | gotowność slave-a na wysłanie danych |
| o_PRDATA    | **3**-bitowe  | dane do wysłania |
| o_PSLVERR   | binarne       | sygnał błądu  |


Możemy zmieniać szerokość bitową **i_PADRR**, **i_PWDATA** oraz **o_PRDATA**  poniważ ona jest zadana za pomocą parametrów. Interfejs AMBA APB uwzględnia pracę z szerokościami tych wejść/wyjść do 32-bitów.


## Master-kontroler

Kontoler pozwala na pracę z jednostkami wykonawczymi przez komunikację z nimi oraz jest głównym sterownikiem naszego układu. Kontroler przyjmuje zadane przez użytkownika dane i po otrzymaniu wyników z powrotem oddaje użytkowniku. *De-facto* posiada dwa interfejsy: do pracy z użytkownikiem oraz APB. 

Kontroler jest przedstawiony kilkoma plikami naraz: 

* APB_master.sv

    Opisuje prace oraz wejścia tego modułu

* Controller_core.sv

    ?

* Controller_wrapper.sv

    ?

* Memory_model.sv

    ?

I jeszce potrzebuje plik simulający pamięć - *mem.data* 