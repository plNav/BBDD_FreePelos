------------------------------------------------ 2 VISTAS  ---------------------------------------------------------------
 -- Esta primera vista es una mejora de la tabla corte_pelo donde sustitituimos los pk's que protegen los datos por  
 	-- otros de interes directo, referenciamos los vinculos con el resto de tablas y anyadimos el calculo del total 
	-- bruto por servicio de manera que para obtener el neto de cada uno de los servicios completos solo faltaria  
	-- aplicar descuentos o incrementos dependiendo de si el lugar es a domicilio, en un centro de trabajo o en 
	-- la casa del trabajador, pero para ello necesitaremos utilizar funciones;									XXXXXX
	
	CREATE VIEW precio_corte_bruto (fecha, codigo, nombre_cliente, direccion, ciudad, servicio, precio_servicio,
									producto, precio_producto, total_bruto ) AS
		SELECT cp.fecha_corte, cl.cod_cliente, cl.nombre_cliente, lu.direccion_lugar, lu.ciudad, se.nom_servicio, 
			se.precio_servicio, pr.nom_prod, pr.precio_prod, (pr.precio_prod + se.precio_servicio) AS total_bruto 
			 FROM corte_pelo cp, cliente cl, lugar lu, productos pr, servicio se
			 WHERE cp.cod_cliente = cl.cod_cliente
				AND cp.cod_lugar = lu.cod_lugar
				AND cp.nom_servicio = se.nom_servicio
				AND cp.cod_producto = pr.cod_prod;
				
	SELECT * FROM precio_corte_bruto;
	
	
 --En esta segunda vista mostramos el masaje que puede incluir gratuitamente cada servicio con su duracion;
 
 	CREATE VIEW masaje_precio (servicio, masaje, duracion, precio) AS
		SELECT se.nom_servicio, ma.tipo_masaje, ma.duracion, se.precio_servicio
			FROM masaje ma, servicio se, anyadir_masaje am
			WHERE se.nom_servicio = am.nom_servicio
				AND ma.tipo_masaje = am.tipo_masaje;
 
	SELECT * FROM masaje_precio;

------------------------------------------------ 2 FUNCIONES  ---------------------------------------------------------------
 -- A la primera funcion le pasaremos como parametro el id de un cliente y la fecha donde se realizo el corte y nos devolvera
 	-- el total del precio con los descuentos o incrementos aplicados dependiendo del lugar donde se realizo; Codigo comentado;
	
	CREATE OR REPLACE FUNCTION precio_neto (cliente_id int, fecha_servicio date)
		RETURNS numeric AS $$
		-- GUARDAMOS EL BRUTO Y COD_LUGAR DE LA VISTA 1 Y CORTE_PELO PARA EL CLIENTE Y FECHA ELEGIDOS;
			DECLARE bruto numeric := (SELECT total_bruto FROM precio_corte_bruto 
										WHERE cliente_id = codigo AND fecha_servicio = fecha);
			DECLARE id_lugar int := (SELECT cod_lugar FROM corte_pelo 
										WHERE cliente_id = cod_cliente AND fecha_servicio = fecha_corte);
		-- PREPARAMOS VARIABLES PARA GUARDAR LOS RESULTADOS;
			DECLARE tasas numeric;
			DECLARE neto numeric;
		BEGIN
		-- IF 1º COMPRUEBA SI EL SERVICIO FUE EN CASA Y APLICA DESCUENTO;
			IF id_lugar = 0 THEN
				tasas := (bruto * 0.15);
				neto := (bruto - tasas);
				RAISE INFO 'EL SERVICIO DE CLIENTE % Y FECHA % FUE EN CASA',cliente_id, fecha_servicio;
		-- IF 2º COMPRUEBA SI EL SERVICIO FUE A DOMICILIO Y APLICA INCREMENTO POR KM;
			ELSIF EXISTS ( SELECT cod_lugar FROM a_domicilio
								WHERE cod_lugar = id_lugar ) THEN
				tasas := ((SELECT distancia FROM a_domicilio WHERE cod_lugar = id_lugar) * 0.20);
				neto := (bruto + tasas);
				RAISE INFO 'EL SERVICIO DE CLIENTE % Y FECHA % FUE A DOMICILIO',cliente_id, fecha_servicio;
		-- IF 3º COMPRUEBA SI EL SERVICIO FUE EN CENTRO DE TRABAJO Y APLICA PORCENTAJES;
			ELSIF EXISTS ( SELECT cod_lugar FROM centro_trabajo
						 	WHERE cod_lugar = id_lugar ) THEN
				tasas := (bruto * ((100 - (SELECT porcentaje FROM centro_trabajo WHERE cod_lugar = id_lugar))/100));
				neto := TRUNC((bruto - tasas),2); 
				RAISE INFO 'EL SERVICIO DE CLIENTE % Y FECHA % FUE EN UN CENTRO DE TRABAJO',cliente_id, fecha_servicio;
		-- SI NO EXISTE EN NINGUN LUGAR LOS PARAMETROS NO SON VALIDOS, INFORMAMOS Y DEVOLVEMOS 0.0
			ELSE 
				RAISE INFO 'NO EXISTE REGISTRO CON CODIGO DE CLIENTE % Y FECHA %',cliente_id, fecha_servicio;
				RETURN 0.0;
			END IF;
		-- SI EXISTE PERO EL CALCULO ES NULL SE ELIMINO EL PRODUCTO O SERVICIO DEL REGISTRO, INFORMAMOS Y DEVOLVEMOS 0.0
			IF neto IS NULL THEN 
				RAISE INFO 'EL SERVICIO O PRODUCTO FUERON ELIMINADOS PARA EL CLIENTE % Y FECHA %',cliente_id, fecha_servicio;
				RETURN 0.0;
			END IF;
		RETURN neto;
		END; 
		$$ LANGUAGE PLPGSQL;
				
	SELECT precio_neto (8, '2018-07-10');	-- DEVUELVE DATO (A_DOMICILIO);
	SELECT precio_neto (5, '2019-02-01');	-- DEVUELVE DATO (CENTRO_TRABAJO);
	SELECT precio_neto (2, '2018-04-05');   -- DEVUELVE 0.0 Y MENSAJE DE ELIMINADO;
	SELECT precio_neto (4, '2010-01-01');	-- DEVUELVE 0.0 INDICANDO QUE NO EXISTE REGISTRO;


 -- Ahora aprovechamos la funcion para crear otra y recorrer con un cursor la vista entre los anyos deseados obteniendo 
 	-- todos los beneficios netos y la suma total de estos los acumulamos en otra variable que agregamos tras el bucle;
	
	CREATE OR REPLACE FUNCTION get_registros (anyo_inicio varchar, anyo_fin varchar)
		RETURNS text AS $$
			DECLARE registros_salida text DEFAULT '';
			DECLARE total_beneficio numeric DEFAULT 0;
			DECLARE record_registros RECORD;
			DECLARE cursor_registros CURSOR
								FOR SELECT fecha, nombre_cliente, codigo, servicio, total_bruto
								FROM precio_corte_bruto
								WHERE TO_CHAR(fecha, 'YYYY') BETWEEN anyo_inicio AND anyo_fin;
		BEGIN 
			OPEN cursor_registros;
			RAISE WARNING 'Como invocamos dos veces la funcion precio_neto, todas las INFO estan duplicadas';
			LOOP
				FETCH cursor_registros INTO record_registros;
				EXIT WHEN NOT FOUND;
				
				registros_salida := registros_salida || '  ----  ' || record_registros.fecha || ';  ' 
				|| record_registros.nombre_cliente || ';  ' || record_registros.servicio || ';  TOTAL NETO => ' 
				|| (SELECT precio_neto ((SELECT cod_cliente FROM corte_pelo 
										WHERE record_registros.codigo = cod_cliente 
											AND record_registros.fecha = fecha_corte),
										record_registros.fecha)) || '€';
				total_beneficio := total_beneficio + (SELECT precio_neto ((SELECT cod_cliente FROM corte_pelo 
										WHERE record_registros.codigo = cod_cliente 
											AND record_registros.fecha = fecha_corte),
										record_registros.fecha));
			END LOOP;
			CLOSE cursor_registros;
			registros_salida := registros_salida || '  >>>>>>>>>>>>  TOTAL DE GANANCIAS => ' || total_beneficio || '€';
			RETURN registros_salida;
		END;
		$$ LANGUAGE PLPGSQL;
		
	SELECT get_registros ('2018', '2021');
	SELECT get_registros ('2020', '2020');
	SELECT get_registros ('2021', '2021'); 

------------------------------------------------ 2 TRIGGERS  ---------------------------------------------------------------
 --Trigger para asegurar que los deletes en productos no puedan afectar al codigo 0;
 
	CREATE OR REPLACE FUNCTION eliminar_producto()
		RETURNS TRIGGER AS $$
			DECLARE codigo int := OLD.cod_prod;
		BEGIN
			IF codigo = 0 THEN
				RAISE EXCEPTION 'TRIGGER: La entrada con codigo 0 no se puede borrar';
			ELSE
				DELETE FROM productos WHERE cod_prod = NEW.cod_prod;
			END IF;
			RETURN OLD;
		END;
		$$ LANGUAGE PLPGSQL;
		
	CREATE TRIGGER protege_productos_delete BEFORE DELETE
		ON productos FOR EACH ROW
		EXECUTE PROCEDURE eliminar_producto();
			
	DELETE FROM productos WHERE cod_prod = 0;
	DELETE FROM productos WHERE cod_prod = 7;
	DELETE FROM productos WHERE nom_prod = 'Producto Obsoleto';
	SELECT * FROM productos;	


-- Esta funcion y trigger se disparan al introducir dos codigos de producto dentro de la tabla combinar,
 	-- se comprueba si el producto existe, en caso afirmativo se suma cantidad al resultado y se resta de 
	-- los sumandos, en caso contrario se crea el nuevo producto y se anyade a la tabla productos;					XXXXXXXXXXX
	CREATE OR REPLACE FUNCTION combinar_productos()
		RETURNS TRIGGER AS $$
			DECLARE cod1 int := NEW.cod_prod1;
			DECLARE cod2 int := NEW.cod_prod2;
			DECLARE nom1 varchar := (SELECT nom_prod FROM productos WHERE cod_prod = cod1);
			DECLARE nom2 varchar := (SELECT nom_prod FROM productos WHERE cod_prod = cod2);
			DECLARE cant1 int := (SELECT cantidad_prod FROM productos WHERE cod_prod = cod1);
			DECLARE cant2 int := (SELECT cantidad_prod FROM productos WHERE cod_prod = cod2);
			DECLARE prec1 numeric := (SELECT precio_prod FROM productos WHERE cod_prod = cod1);
			DECLARE prec2 numeric := (SELECT precio_prod FROM productos WHERE cod_prod = cod2);
			DECLARE nom_combinado varchar := nom1 || ' - ' || nom2;
			DECLARE precio_combinado numeric := prec1 + prec2;
		BEGIN
			IF cant1 > 0 AND cant2 > 0 THEN
				IF EXISTS (SELECT nom_prod FROM productos WHERE nom_prod = nom_combinado) THEN
					RAISE INFO 'Trigger de combinacion que actualiza las cantidades en productos';
					UPDATE productos SET cantidad_prod = cantidad_prod -1 WHERE cod_prod = cod1;
					UPDATE productos SET cantidad_prod = cantidad_prod -1 WHERE cod_prod = cod2;
					UPDATE productos SET cantidad_prod = cantidad_prod +1 WHERE nom_prod = nom_combinado;
				ELSE
					RAISE INFO 'Trigger de combinacion que anyade un nuevo producto y resta cantidades';
					UPDATE productos SET cantidad_prod = cantidad_prod -1 WHERE cod_prod = cod1;
					UPDATE productos SET cantidad_prod = cantidad_prod -1 WHERE cod_prod = cod2;
					INSERT INTO productos (nom_prod, descr_prod, cantidad_prod, precio_prod)
						VALUES (nom_combinado, 'Combinacion', 1, precio_combinado);
				END IF;
			ELSE
					RAISE INFO 'Combinacion fallida, no hay suficientes productos para % ', nom_combinado;
			END IF;
			RETURN NEW;
		END;
		$$ LANGUAGE PLPGSQL;
		
	CREATE TRIGGER actualiza_cantidades BEFORE INSERT
		ON combinar FOR EACH ROW
		EXECUTE PROCEDURE combinar_productos();
	
	INSERT INTO combinar (cod_prod1, cod_prod2) VALUES (0,5);
	INSERT INTO combinar (cod_prod1, cod_prod2) VALUES (3,4);

	SELECT * FROM productos;
	SELECT * FROM combinar;

	





	