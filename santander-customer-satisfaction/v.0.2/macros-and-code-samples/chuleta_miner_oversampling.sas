/*

PARA PROBAR OVERSAMPLING:

1) Nodo muestra: 
en variables, marcar como estratificación la variable 
dependiente
2) Metodo muestra: estratificar
3)Criterio: basado en nivel

4) Seleccion de nivel : Evento (si tenemos una variable dependiente
0-1, el "evento" es el 1)

5) Calcular los tamaños muestrales absolutos finales 
que se desean

6) Calcular 
*proporcion de nivel=% de obs "evento" en la muestra
final respecto de la muestra inicial
*proporción muestral=% de obs de "evento" en la muestra final.




Para aplicarlo sobre datos test y comparar under-oversampling con 
"no hacer nada":

1) PARTICIONAR LOS DATOS EN TRAIN Y TEST CON EL NODO DE PARTICIÓN
2) GUARDAR LOS ARCHIVOS TRAIN Y TEST YENDO AL EXPLORADOR DE ARCHIVOS+BOTON DERECHO+NUEVA FUENTE DE DATOS
3) APLICAR LOS PASOS ANTERIORES PARA CREAR UN ARCHIVO DE OVERSAMPLING A PARTIR DE LOS DATOS TRAIN
4) 


i) Crear regresión1 o red a partir del nodo muestra-bis-train (los de oversampling)
ii) Crear regresión2 o red a partir del nodo datos originales train
iii) Enlazar el archivo test a un nodo de puntuación1 y la regresión1 también 
a ese nodo
iv) Enlazar el archivo test a un nodo de puntuación2 y la regresión2 también 
a ese nodo
v) enlazar los dos nodos de puntuación a un nodo de comparación de modelos
vi) En el nodo del archivo test:Rol prueba
	En puntuación1 y puntuación2: Datos de puntuación-prueba Sí
	En nodo comparación de modelos: 
			Volver a calcular Sí
			Estadístico de selección: indice de clasificación
			Tabla de selección: entrenamiento


*/



