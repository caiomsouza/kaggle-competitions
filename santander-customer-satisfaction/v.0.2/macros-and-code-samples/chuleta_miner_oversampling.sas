/*

PARA PROBAR OVERSAMPLING:

1) Nodo muestra: 
en variables, marcar como estratificaci�n la variable 
dependiente
2) Metodo muestra: estratificar
3)Criterio: basado en nivel

4) Seleccion de nivel : Evento (si tenemos una variable dependiente
0-1, el "evento" es el 1)

5) Calcular los tama�os muestrales absolutos finales 
que se desean

6) Calcular 
*proporcion de nivel=% de obs "evento" en la muestra
final respecto de la muestra inicial
*proporci�n muestral=% de obs de "evento" en la muestra final.




Para aplicarlo sobre datos test y comparar under-oversampling con 
"no hacer nada":

1) PARTICIONAR LOS DATOS EN TRAIN Y TEST CON EL NODO DE PARTICI�N
2) GUARDAR LOS ARCHIVOS TRAIN Y TEST YENDO AL EXPLORADOR DE ARCHIVOS+BOTON DERECHO+NUEVA FUENTE DE DATOS
3) APLICAR LOS PASOS ANTERIORES PARA CREAR UN ARCHIVO DE OVERSAMPLING A PARTIR DE LOS DATOS TRAIN
4) 


i) Crear regresi�n1 o red a partir del nodo muestra-bis-train (los de oversampling)
ii) Crear regresi�n2 o red a partir del nodo datos originales train
iii) Enlazar el archivo test a un nodo de puntuaci�n1 y la regresi�n1 tambi�n 
a ese nodo
iv) Enlazar el archivo test a un nodo de puntuaci�n2 y la regresi�n2 tambi�n 
a ese nodo
v) enlazar los dos nodos de puntuaci�n a un nodo de comparaci�n de modelos
vi) En el nodo del archivo test:Rol prueba
	En puntuaci�n1 y puntuaci�n2: Datos de puntuaci�n-prueba S�
	En nodo comparaci�n de modelos: 
			Volver a calcular S�
			Estad�stico de selecci�n: indice de clasificaci�n
			Tabla de selecci�n: entrenamiento


*/



