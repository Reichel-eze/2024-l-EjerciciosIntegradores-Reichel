% Ejercicios Integradores

% ----------------- VUELOS --------------------

% Una agencia de viajes lleva un registro con todos los vuelos que maneja de la siguiente manera:
% vuelo(Codigo de vuelo, capacidad en toneladas, [lista de destinos]).
% Esta lista de destinos está compuesta de la siguiente manera:
% - escala(ciudad, tiempo de espera)
% - tramo(tiempo en vuelo)
% Siempre se comienza de una ciudad (escala) y se termina en otra (no puede terminar en el aire al vuelo), 
% con tiempo de vuelo entre medio de las ciudades. Considerar que los viajes son de ida y de vuelta por la misma ruta.

vuelo(arg845, 30, [escala(rosario,0), tramo(2), escala(buenosAires,0)]).

vuelo(mh101, 95, [escala(kualaLumpur,0), tramo(9), escala(capeTown,2), tramo(15), escala(buenosAires,0)]).

vuelo(dlh470, 60, [escala(berlin,0), tramo(9), escala(washington,2), tramo(2), escala(nuevaYork,0)]).

vuelo(aal1803, 250, [escala(nuevaYork,0), tramo(1), escala(washington,2),
tramo(3), escala(ottawa,3), tramo(15), escala(londres,4), tramo(1),
escala(paris,0)]).

vuelo(ble849, 175, [escala(paris,0), tramo(2), escala(berlin,1), tramo(3),
escala(kiev,2), tramo(2), escala(moscu,4), tramo(5), escala(seul,2), tramo(3), escala(tokyo,0)]).

vuelo(npo556, 150, [escala(kiev,0), tramo(1), escala(moscu,3), tramo(5),
escala(nuevaDelhi,6), tramo(2), escala(hongKong,4), tramo(2), escala(shanghai,5), tramo(3), escala(tokyo,0)]).

vuelo(dsm3450, 75, [escala(santiagoDeChile,0), tramo(1), escala(buenosAires,2), tramo(7), escala(washington,4),
tramo(15), escala(berlin,3), tramo(15), escala(tokyo,0)]).

% 1) tiempoTotalVuelo/2 : Relaciona un vuelo con el tiempo que lleva en total, contando las esperas en las escalas
% (y eventualmente en el origen y/o destino) más el tiempo de vuelo.

tiempoTotalVuelo(Vuelo, TiempoTotal) :-
    vuelo(Vuelo, _, Destinos),
    findall(TiempoEscala, member(escala(_, TiempoEscala), Destinos), TiemposEscalas),
    findall(TiempoTramo, member(tramo(TiempoTramo), Destinos), TiemposTramos),
    sum_list(TiemposEscalas, TotalEscalas),
    sum_list(TiemposTramos, TotalTramos),
    TiempoTotal is TotalEscalas + TotalTramos.

% DEMASIADA REPETICION DE LOGICA, LO PUEDO HACER CON POLIMORFISMO (ACA ABAJO)!!

tiempoTotalVueloV2(Vuelo, TiempoTotal) :-
    vuelo(Vuelo, _, _),
    findall(Duracion, (destino(Vuelo, Destino), duracion(Destino, Duracion)), Duraciones),
    sum_list(Duraciones, TiempoTotal).

destino(Vuelo, Destino) :-      % relacion un vuelo con un destino (el Destino forma parte de los Destinos del Vuelo)
    vuelo(Vuelo, _, Destinos),
    member(Destino, Destinos).
    
duracion(escala(_, TiempoDeEspera), TiempoDeEspera).
duracion(tramo(TiempoEnVuelo), TiempoEnVuelo).    

% 2) escalaAburrida/2 : Relaciona un vuelo con cada una de sus escalas aburridas; una escala es aburrida si 
% hay que esperar mas de 3 horas.
    
escalaAburrida(Vuelo, Escala) :-
    escalaDeVuelo(Vuelo, Escala),    % 1ero tengo que decir que es una escala!!
    duracion(Escala, Duracion),      % uso duracion de arriba   
    Duracion > 3.                    % para que sea aburrida

escalaDeVuelo(Vuelo, escala(Ciudad, Tiempo)) :- % me dice las escalas que tiene un vuelo!!
    destino(Vuelo, escala(Ciudad, Tiempo)).  

% 3) ciudadesAburridas/2 : Relaciona un vuelo con la lista de ciudades de sus escalas aburridas.

ciudadesAburridas(Vuelo, Ciudades) :-
    vuelo(Vuelo, _, _),
    findall(Ciudad, (escalaAburrida(Vuelo, Escala), ciudadEscala(Escala, Ciudad)), Ciudades).

ciudadEscala(escala(CiudadEscala, _), CiudadEscala).

% 4) vueloLargo/1: Si un vuelo pasa 10 o más horas en el aire, 
% entonces es un vuelo largo. OJO que dice "en el aire", en este punto 
% no hay que contar las esperas en tierra. 

vueloLargo(Vuelo) :-
    tiempoTotalEnElAire(Vuelo, TiempoTotal),
    TiempoTotal > 10.

tiempoTotalEnElAire(Vuelo, TiempoEnElAire) :-
    vuelo(Vuelo, _, _),
    findall(Tiempo, (tramoDeVuelo(Vuelo, Tramo), duracion(Tramo, Tiempo)), Tiempos),
    sum_list(Tiempos, TiempoEnElAire).
    
tramoDeVuelo(Vuelo, tramo(Tiempo)) :- % me dice los tramos que tiene un vuelo!!
    destino(Vuelo, tramo(Tiempo)).

% 4.1) conectados/2: Relaciona 2 vuelos si tienen al menos una ciudad en común.

conectados(Vuelo, OtroVuelo) :-
    pasaPorCiudad(Vuelo, Ciudad),
    pasaPorCiudad(OtroVuelo, Ciudad),
    Vuelo \= OtroVuelo.

pasaPorCiudad(Vuelo, Ciudad) :-
    escalaDeVuelo(Vuelo, Escala),   % la escala forma parte del vuelo   --> le podria poner destino(Vuelo, Destino), 
    ciudadEscala(Escala, Ciudad).   % la ciudad de dicha escala         --> y despues que me diga la ciudad de ese destino ciudad(Destino, Ciudad).

% 7) vueloLento/1: Un vuelo es lento si no es largo, y además cada escala es aburrida.

vueloLento(Vuelo) :-
    vuelo(Vuelo, _, _),
    not(vueloLargo(Vuelo)),
    forall(escalaDeVuelo(Vuelo, Escala), escalaAburrida(Vuelo, Escala)).
    % para todoas las escalas del vuelo, son aburridas

% 5) bandaDeTres/3: Relaciona 3 vuelos si están conectados, el primero
% con el segundo, y el segundo con el tercero.

bandaDeTres(Vuelo1, Vuelo2, Vuelo3) :-
    conectados(Vuelo1, Vuelo2),
    conectados(Vuelo2, Vuelo3),
    Vuelo1 \= Vuelo3.

% 6) distanciaEnEscalas/3: Relaciona dos ciudades que son escalas 
% del mismo vuelo y la cantidad de escalas entre las mismas; si 
% no hay escalas intermedias la distancia es 1. P.ej. 
% - París y Berlín están a distancia 1 (por el vuelo BLE849), 
% - Berlín y Seúl están a distancia 3 (por el mismo vuelo). 
% No importa de qué vuelo, lo que tiene que pasar es que haya algún 
% vuelo que tenga como escalas a ambas ciudades. Consejo: usar nth1

% ME IMPORTA EL ORDEN DE LA LISTA!!

distanciaEnEscalas(Ciudad1, Ciudad2, Distancia) :-      % EN ESTE NO VA A VER PROBLEMAS DE ORDEN!!
    vuelo(Vuelo, _, Destinos),
    pasaPorCiudad(Vuelo, Ciudad1),
    pasaPorCiudad(Vuelo, Ciudad2),
    nth1(M, Destinos, escala(Ciudad1, _)),
    nth1(N, Destinos, escala(Ciudad2, _)),
    findall(CiudadIntermedia,
         (nth1(X, Destinos, escala(CiudadIntermedia, _)), entre(M,N,X)), CiudadesIntermedias),
    length(CiudadesIntermedias, CantCiudadesIntermedias),
    Distancia is 1 + CantCiudadesIntermedias.

entre(Superior, Inferior, X) :-
    Inferior < X, Superior > X.

entre(Inferior, Superior, X) :-
    Inferior < X, Superior > X.

distanciaEnEscalasV2(Ciudad1, Ciudad2, Distancia) :-
    vuelo(Vuelo, _, _),
    pasaPorCiudad(Vuelo, Ciudad1),
    pasaPorCiudad(Vuelo, Ciudad2),
    %findall(Ciudad, member((escala(Ciudad, _)), Destinos), Ciudades),   % hago una lista de ciudades (puede hacer una funcion auxiliar abajo)
    ciudadesVuelo(Vuelo, Ciudades),
    nth1(M, Ciudades, Ciudad1), % obtengo la posicion de la primera ciudad
    nth1(N, Ciudades, Ciudad2), % obtengo la posicion de la segunda ciudad
    Distancia is abs(M - N).    % obtengo la distancia absoluta enntre las posiciones de ambas ciudades (no me importa el orden de como paso las ciudades)

ciudadesVuelo(Vuelo, Ciudades) :-
    vuelo(Vuelo, _, _),
    findall(Ciudad, pasaPorCiudad(Vuelo, Ciudad), Ciudades).
    