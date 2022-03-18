		------ (A) 5 CONSULTAS SIMPLES DE UNA SOLA TABLA ------
		
 -- Muestra todo el contenido de la tabla mas importante sin ninguna modificacion, 
 	-- quiero mostrarla asi de primeras para luego ir ensenyando lo que voy haciendo.              XXXXXXXXX 000
	SELECT * FROM corte_pelo;
	
 -- Muestra el codigo 0, esta fila no se podra eliminar (por triggers), de esta manera
 	-- podremos eliminar cualquier producto y los FK de otras tablas pasaran a referenciar al 0
	-- evitando asi posibles errores o perdida de informacion. 
	SELECT cod_prod, nom_prod, descr_prod
		FROM productos
		WHERE cod_prod = 0;
		
 -- Como en el caso anterior, ocurre lo mismo con las herramientas
 	SELECT cod_herram, nom_herram, descr_herram
		FROM herramientas
		WHERE nom_herram LIKE 'B%';
		
 -- Acota los registros con un determinado numero de fotos o videos
	SELECT num_fotos, num_videos, fecha_registro, nom_servicio
		FROM registro_multimedia 
		WHERE num_fotos > 20 
			OR num_videos > 10;
			
 -- Muestra los diferentes tipos de sexo que se tienen en cuenta
	SELECT DISTINCT sexo FROM cliente;

  --------------------------------------------------------------------------
		------ (B) 2 UPDATES Y 2 DELETES EN CUALQUIER TABLA  ------
		
	UPDATE cliente SET sexo = 'X' WHERE sexo IS NULL; -- La mitad de los inserts estan sin sexo
	
	UPDATE herramientas SET cod_herram = 333 WHERE cod_herram = 7; -- Desencadena UPDATE CASCADE en UTILIZAR
		--SELECT * FROM herramientas;
		--SELECT * FROM utilizar;

	DELETE FROM productos WHERE cod_prod = 1; -- Desencadena DELETE SET DEFAULT en CORTE_PELO y GASTAR        XXXXXXXX    11111
		--SELECT * FROM corte_pelo;
	
	DELETE FROM corte_pelo WHERE fecha_corte 
		BETWEEN '2019-06-19' AND '2019-08-19'; -- Desencadena DELETE SET NULL en REGISTRO_MULTIMEDIA y GASTAR
		--SELECT * FROM registro_multimedia;

  --------------------------------------------------------------------------
		------ (C) 3 CONSULTAS CON MAS DE UNA TABLA ------
		
 -- Muestra el nombre de las herramientas, el precio y el servicio donde se usan ordenadas por precio
	SELECT h.nom_herram AS herramienta, h.precio_herram AS precio_euros, u.nom_servicio AS servicio_donde_se_usa
		FROM herramientas h, utilizar u
		WHERE h.cod_herram = u.cod_herram 
			AND h.precio_herram > 800
		ORDER BY h.precio_herram DESC;

 -- Muestra la distancia desde casa a las direcciones y ciudades mas lejanas, ordenado por distancia                XXXXXXXXXX   22222
	SELECT d.distancia AS km, l.ciudad, l.direccion_lugar AS direccion
		FROM a_domicilio d, lugar l
		WHERE d.cod_lugar = l.cod_lugar 
			AND d.distancia > 50
		ORDER BY km DESC;
	
 -- Muestra los cortes a partir del 2020 ordenados por fecha, aparece nombre del cliente, 
 	-- su direccion y ciudad, el producto utilizado y el servicio que consumio.
 	SELECT cp.fecha_corte AS fecha, cl.nombre_cliente AS cliente, lu.ciudad,
	lu.direccion_lugar AS direccion, pr.nom_prod AS producto_usado, cp.nom_servicio AS servicio
		FROM corte_pelo cp, cliente cl, lugar lu, productos pr
		WHERE cp.cod_cliente = cl.cod_cliente
			AND cp.cod_lugar = lu.cod_lugar
			AND cp.cod_producto = pr.cod_prod
			AND TO_CHAR(cp.fecha_corte, 'YYYY') >= '2020'
		ORDER BY fecha;
		
  --------------------------------------------------------------------------
		------ (D) 3 CONSULTAS USANDO FUNCIONES ------	
		
 -- Media de todos los masajes
	SELECT AVG (duracion) AS media_minutos_masajes
		FROM masaje;
		
 -- Total de clientes registrados
	SELECT COUNT(*) as clientes_registrados
		FROM cliente;

 -- Muestra el coste del servicio y el producto de los anyos seleccionados
 	SELECT SUM(se.precio_servicio + pr.precio_prod) AS ganancia_bruto
		FROM corte_pelo cp, servicio se, productos pr
		WHERE cp.cod_producto = pr.cod_prod
			AND cp.nom_servicio = se.nom_servicio
			AND TO_CHAR(cp.fecha_corte, 'YYYY') IN ('2018','2020');

  --------------------------------------------------------------------------
		------ (E) 2 CONSULTAS USANDO GROUP BY ------	
		
 -- Muestra el total obtenido por servicio y el numero de veces que se ha realizado                  XXXXXXXXXX  33333
	SELECT cp.nom_servicio, SUM(se.precio_servicio) AS total_por_servicio, COUNT(cp.nom_servicio) AS veces
		FROM corte_pelo cp, servicio se
		WHERE cp.nom_servicio = se.nom_servicio
		GROUP BY cp.nom_servicio
		ORDER BY total_por_servicio DESC;

 -- Muestra el total obtenido por cada cliente por servicio   							XXXXXXXX  444
	SELECT c.nombre_cliente, s.precio_servicio, s.nom_servicio
		FROM cliente c, servicio s, corte_pelo p
		WHERE s.precio_servicio > 10 
			AND c.cod_cliente = p.cod_cliente 
			AND s.nom_servicio = p.nom_servicio
		GROUP BY c.nombre_cliente, s.precio_servicio, s.nom_servicio
		ORDER BY s.precio_servicio DESC;

  --------------------------------------------------------------------------
		------ (F) 2 CONSULTAS UTILIZANDO SUBCONSULTAS ------
		
 -- Muestra qué tipo de masaje incluyó cada servicio realizado 
	 SELECT *
		 FROM anyadir_masaje
		 WHERE nom_servicio IN (SELECT nom_servicio FROM corte_pelo);
	 
 -- Muestra el nombre del cliente que tuvo el servicio más barato por producto (3 subconsultas anidadas)         XXXXXXXXXXX   5555
 	SELECT nombre_cliente AS cliente_mas_tacanyo
		FROM cliente
		WHERE cod_cliente = 
			(SELECT cod_cliente FROM corte_pelo  WHERE nom_servicio = 
				(SELECT nom_servicio FROM servicio WHERE precio_servicio =
					(SELECT MIN(precio_servicio) FROM servicio)));
	 
  --------------------------------------------------------------------------
		------ (G) 2 CONSULTAS UTILIZANDO GROUP BY y HAVING ------
		
 -- Muestra el total por servicio de los servicios que al menos se hayan realizado 2 veces 
	SELECT cp.nom_servicio, SUM(se.precio_servicio) AS total_por_servicio, COUNT(cp.nom_servicio) AS veces
		FROM corte_pelo cp, servicio se
		WHERE cp.nom_servicio = se.nom_servicio
		GROUP BY cp.nom_servicio
		HAVING COUNT(cp.nom_servicio) >= 2;

 -- Muestra el total de gasto por productos de los productos que al menos se hayan gastado 2 veces					XXXXXXXX 666
	SELECT pr.nom_prod AS producto, SUM(pr.precio_prod) AS total_gasto, COUNT(cp.cod_producto) AS veces_usado
		FROM productos pr, corte_pelo cp
		WHERE pr.cod_prod = cp.cod_producto
		GROUP BY pr.nom_prod
		HAVING COUNT(cp.cod_producto) >= 2;
		
  --------------------------------------------------------------------------
		------ (H) 3 UPDATES USANDO SUBCONSULTAS EN WHERE Y SET ------
		
 -- Copia las preferencias del cliente con pk 5 en el 9
	UPDATE cliente
		SET preferencias = (
			SELECT preferencias 
			FROM cliente
			WHERE cod_cliente = 5
		)
		WHERE nombre_cliente = (
			SELECT nombre_cliente
			FROM cliente
			WHERE cod_cliente = 9
		);
		
 -- SELECT * FROM cliente;
		
 -- Cambia el pk de herramienta 4 por 60; Desencadena UPDATE CASCADE en UTILIZAR
 
 --LOS DOS UPDATES SON DIFICILES DE APRECIAR ANTES DE LA VISTA;
 
	UPDATE herramientas
		SET cod_herram = (
			SELECT (cod_prod * 10)
			FROM productos
			WHERE nom_prod = 'Mascarilla Natural'
		)
		WHERE cod_herram = (
			SELECT cod_cliente
			FROM corte_pelo
			WHERE fecha_corte = '2019-11-18');
			
			
 -- Cambia el cod_prod de 5 a 80; Desencadena UPDATE CASCADE en CORTE_PELO
	 UPDATE productos
	 	SET cod_prod = (
			SELECT (cod_cliente * 20)
			FROM corte_pelo
			WHERE fecha_corte = '2019-11-18'
		)
		WHERE cod_prod = (
			SELECT cod_lugar
			FROM corte_pelo
			WHERE nom_servicio = 'Permanente'
				AND cod_cliente = 5
		);


