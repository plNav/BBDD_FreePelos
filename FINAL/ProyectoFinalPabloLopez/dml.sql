--------TABLA CLIENTE--------
	INSERT INTO cliente (nombre_cliente, telefono, preferencias, sexo)
	VALUES 
		('Misis One', 1234567, 'Corte y Tinte', 'M'),
		('Don Two', 4567473, 'Rapado al 0', 'H'),
		('Lady Three', 45645645, 'Corte a la antigua', 'M'),
		('Mister Four', 45688942, 'Rapado Demoníaco', 'H'),
		('Sir Five', 23476794, 'Corte Militar', 'H');

	INSERT INTO cliente (nombre_cliente, telefono)
	VALUES
		('Queen Six', 389432),
		('Maese Seven', 795950),
		('Duquesa Eight', 079067456),
		('Nine-Chan', 067453623),
		('Hokage Ten', 0674567);

	--SELECT * FROM cliente;

--------TABLA SERVICIO--------
	INSERT INTO servicio
	VALUES
		('Corte Simple', 'Lavar y cortar', 20),
		('Corte Doble', 'Lavar y cortar 2 pax', 30),
		('Corte Especial', 'Secado especial', 40),
		('Corte y Tinte', 'Pr de gama alta', 50),
		('Corte Eco', 'poco pelo',10);

	INSERT INTO servicio (nom_servicio, precio_servicio)
	VALUES
		('Corte Samurai', 100),
		('Permanente', 200),
		('Corte Laser', 300),
		('Japonés', 150),
		('Ochentero', 60);

	--SELECT * FROM servicio;

--------TABLA LUGAR--------
	INSERT INTO lugar
	VALUES (000, 'Direccion Casa', 'Benidorm');

	INSERT INTO lugar (direccion_lugar, ciudad)
	VALUES 
		('Calle Stephen King 19', 'Misery City'),
		('Calle Brandom Sanderson 14', 'Ciudad de las Brumas'),
		('Calle Patrick Rothfuss 33', 'Ciudad del Silencio'),
		('Calle Shinigami', 'Tokio'),
		('Complejo Umbrella', 'Raccon City'),
		('Mansion Hellsing', 'New York'),
		('Marine Ford', 'Grand Line'),
		('Calle Ichigo', 'Karakura Town'),
		('Calle Songbird 3', 'Columbia');

	--SELECT * FROM lugar;

--------TABLA MASAJE--------
	INSERT INTO masaje
	VALUES
		('Completo', 60),
		('Medio', 30),
		('Piernas', 20),
		('Brazos', 20),
		('Cabeza', 15),
		('Vietnamita', 90),
		('Turco', 45),
		('Sueco', 35),
		('Shiatsu', 60),
		('Lumbar', 15);

	--SELECT * FROM masaje;

--------TABLA AGREGAR_MASAJE--------
	INSERT INTO anyadir_masaje
	VALUES 
		('Completo', 'Corte Especial'),
		('Cabeza', 'Corte Simple'),
		('Piernas', 'Corte Doble'),
		('Brazos', 'Corte y Tinte'),
		('Medio', 'Corte Eco'),
		('Shiatsu', 'Japonés'),
		('Cabeza', 'Corte Especial'),
		('Sueco','Ochentero'),
		('Lumbar','Permanente'),
		('Vietnamita', 'Corte Laser');

	--SELECT * FROM anyadir_masaje;

--------TABLA CASA-------
	INSERT INTO casa
	VALUES  (0, 15); 
		--Si el lugar es casa habra 15%
	--SELECT * FROM casa;

--------TABLA A_DOMICILIO-------
	INSERT INTO a_domicilio
	VALUES 
		(1, 50),
		(2, 100),
		(3, 300),
		(4, 900),
		(8, 500),
		(9, 800);

	--SELECT * FROM a_domicilio;

--------TABLA CENTRO_TRABAJO-------
	INSERT INTO centro_trabajo
	VALUES 
		(5, 'TVIRUSZ00MB1', '00:00 - 08:00', 60),
		(7, 'ECH1R00DA', '02:00 - 22:00', 40);

	INSERT INTO centro_trabajo (cod_lugar, cif, porcentaje)
	VALUES (6, '41UC4RD', 50);

	--SELECT * FROM centro_trabajo;

--------TABLA HERRAMIENTAS--------
	INSERT INTO herramientas
	VALUES (000, 'Borrado u Obsoleto', 'Herramienta no disponible, borrada u obsoleta', '0');

	INSERT INTO herramientas (nom_herram, precio_herram)
	VALUES
			('Tijeras Schvarosky', 400),
			('Harusame', 900),
			('Longclaw', 300),
			('Masamune', 1000),
			('X-Gun', 200),
			('Secador Solar', 100),
			('Andúril', 3000),
			('Oathkeeper', 200),
			('Rizador de Saúco', 900);

	--SELECT * FROM herramientas;

--------TABLA UTILIZAR--------
	INSERT INTO utilizar
	VALUES
			('Corte Eco', 1),
			('Corte Eco', 9),
			('Corte Especial', 3),
			('Corte Doble', 7),
			('Permanente', 7),
			('Japonés', 4),
			('Japonés', 5),
			('Ochentero', 2),
			('Corte Samurai', 4),
			('Corte y Tinte', 8);

	--SELECT * FROM utilizar;

--------TABLA PRODUCTOS--------
	INSERT INTO productos(cod_prod, nom_prod, descr_prod, cantidad_prod, precio_prod)
	VALUES (000, 'Producto Obsoleto', 'El producto ya no existe o no se utiliza',0,0);

	INSERT INTO productos (nom_prod, cantidad_prod, precio_prod)
	VALUES
		('Tinte Revlon', 5, 20),
		('Decolorador Natural', 2, 30),
		('Tinte Schwarzkopzt', 10, 40),
		('Tinte Loreal', 20, 15),
		('Reparador Loreal', 50, 10),
		('Mascarilla Natural', 10, 30),
		('Eliminador de Residuios Schwarzkopzt', 5, 25),
		('Champu Anticaida Revlon', 8, 8),
		('Antigrasa Loreal', 5, 14);

	--SELECT * FROM productos;
		--En la tabla combinar y gastar no hago inserts aun, hare un trigger
		--para que cada insert disminuya la cantidad de los productos;

--------TABLA CORTE_PELO--------
	INSERT INTO corte_pelo
	VALUES 
			('05-04-2021', 1, 1, 'Corte Eco', 1),
			('19-07-2019', 2, 2, 'Corte Simple', 2),
			('11-09-2020', 3, 3, 'Corte Simple', 3),
			('18-11-2019', 4, 4, 'Corte Especial', 4),
			('01-02-2019', 5, 5, 'Permanente', 5),
			('02-02-2021', 6, 6, 'Corte Doble', 6),
			('08-12-2019', 7, 7, 'Ochentero', 7),
			('10-07-2018', 8, 8, 'Corte Samurai', 8),
			('26-01-2019', 9, 9, 'Japonés', 9),
			('15-11-2020', 1, 2, 'Japonés', 3),
			('22-09-2018', 4, 5, 'Corte y Tinte', 6),
			('09-07-2020', 7, 8, 'Corte Especial', 9);

	--SELECT * FROM corte_pelo;

--------TABLA REGISTRO_MULTIMEDIA--------
	INSERT INTO registro_multimedia (num_fotos, num_videos, fecha_registro, cod_cliente, cod_lugar, nom_servicio)	
	VALUES
			(20,5,'19-07-2019', 2, 2, 'Corte Simple'),
			(2,0,'11-09-2020', 3, 3, 'Corte Simple'),
			(50,18,'18-11-2019', 4, 4, 'Corte Especial'),
			(10,1,'01-02-2019', 5, 5, 'Permanente'),
			(14,12,'02-02-2021', 6, 6, 'Corte Doble'),
			(30,6,'10-07-2018', 8, 8, 'Corte Samurai'),
			(20,1,'26-01-2019', 9, 9, 'Japonés'),
			(0,10,'15-11-2020', 1, 2, 'Japonés'),
			(0,2,'22-09-2018', 4, 5, 'Corte y Tinte'),
			(15,3,'09-07-2020', 7, 8, 'Corte Especial');

	--SELECT * FROM registro_multimedia;











