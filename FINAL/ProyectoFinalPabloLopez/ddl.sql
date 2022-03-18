
	CREATE TABLE cliente(
	cod_cliente SERIAL NOT NULL,
	nombre_cliente varchar (50),
	telefono numeric (10), 
	preferencias varchar (100) DEFAULT 'Sin preferencias',
	sexo varchar (10),
	CONSTRAINT PK_CLIENTE PRIMARY KEY (cod_cliente)
	);

	CREATE TABLE lugar(
	cod_lugar SERIAL NOT NULL,
	direccion_lugar varchar (100),
	ciudad varchar (50),
	CONSTRAINT PK_LUGAR PRIMARY KEY (cod_lugar)
	);

	CREATE TABLE servicio(
	nom_servicio varchar (50) NOT NULL,
	descr_servicio varchar (100) DEFAULT 'Sin descripción', 
	precio_servicio numeric (5) CHECK (precio_servicio >= 0),
	CONSTRAINT PK_SERVICIO PRIMARY KEY (nom_servicio)
	);

	CREATE TABLE masaje (
	tipo_masaje varchar (50) NOT NULL,
	duracion int CHECK (duracion >= 0), -- MINUTOS
	CONSTRAINT PK_MASAJE PRIMARY KEY (tipo_masaje)
	);

	CREATE TABLE anyadir_masaje (
	tipo_masaje varchar (50) NOT NULL,
	nom_servicio varchar (50) NOT NULL,
	CONSTRAINT PK_ANYADIR_MASAJE PRIMARY KEY (tipo_masaje, nom_servicio),
	CONSTRAINT FK_ANYADIR_TIPO FOREIGN KEY (tipo_masaje)
		REFERENCES masaje (tipo_masaje),
	CONSTRAINT FK_ANYADIR_SERVICIO FOREIGN KEY (nom_servicio)
		REFERENCES servicio (nom_servicio)
	);

	CREATE TABLE a_domicilio(
	cod_lugar int NOT NULL, 
	distancia numeric(5) CHECK (distancia >= 0),
	CONSTRAINT PK_DOMICILIO PRIMARY KEY (cod_lugar),
	CONSTRAINT FK_DOMICILIO FOREIGN KEY (cod_lugar)
		REFERENCES lugar (cod_lugar)
	);

	CREATE TABLE casa(
	cod_lugar int NOT NULL,
	descuento numeric (5) CHECK (descuento >= 0),
	CONSTRAINT PK_CASA PRIMARY KEY (cod_lugar),
	CONSTRAINT FK_CASA FOREIGN KEY (cod_lugar)
		REFERENCES lugar(cod_lugar)
	);

	CREATE TABLE centro_trabajo(
	cod_lugar int NOT NULL,
	cif varchar(20) NOT NULL,
	horario varchar (50) DEFAULT '09:00 - 21:00',
	porcentaje numeric (5) CHECK (porcentaje >= 0),
	CONSTRAINT PK_CENTRO PRIMARY KEY (cod_lugar),
	CONSTRAINT FK_CENTRO FOREIGN KEY (cod_lugar)
		REFERENCES lugar(cod_lugar)
	);

	CREATE TABLE herramientas(
	cod_herram SERIAL NOT NULL,
	nom_herram varchar (50),
	descr_herram varchar (100) DEFAULT 'Sin descripción',
	precio_herram numeric (10) CHECK (precio_herram >= 0),
	CONSTRAINT PK_HERRAMIENTAS PRIMARY KEY (cod_herram)
	);

	CREATE TABLE utilizar(
	nom_servicio varchar(50) NOT NULL,
	cod_herram int NOT NULL DEFAULT 000,
	CONSTRAINT PK_UTILIZAR PRIMARY KEY (nom_servicio, cod_herram),
	CONSTRAINT FK_UTILIZAR_SERVICIO FOREIGN KEY (nom_servicio)
		REFERENCES servicio (nom_servicio),
	CONSTRAINT FK_UTILIZAR_HERRAMIENTA FOREIGN KEY (cod_herram)
		REFERENCES herramientas (cod_herram)
		ON UPDATE CASCADE
		ON DELETE SET DEFAULT
	);

	CREATE TABLE productos (
	cod_prod SERIAL NOT NULL,
	nom_prod varchar (150),
	descr_prod varchar (100) DEFAULT 'Sin descripción',
	cantidad_prod numeric (5) CHECK (cantidad_prod >= 0),
	precio_prod numeric (5) CHECK (precio_prod >= 0),
	CONSTRAINT PK_PRODUCTOS PRIMARY KEY (cod_prod)
	);

	CREATE TABLE combinar (
	num_combinacion SERIAL NOT NULL, --Tengo que crear un pk adicional 
	cod_prod1 int NOT NULL DEFAULT 0, --para poder repetir las combinaciones
	cod_prod2 int NOT NULL DEFAULT 0, 
	CONSTRAINT PK_COMBINAR PRIMARY KEY (num_combinacion, cod_prod1, cod_prod2),
	CONSTRAINT FK_COMBINAR1 FOREIGN KEY (cod_prod1)
		REFERENCES productos (cod_prod)
			ON UPDATE CASCADE
			ON DELETE SET DEFAULT,
	CONSTRAINT FK_COMBINAR2 FOREIGN KEY (cod_prod2)
		REFERENCES productos (cod_prod)
			ON UPDATE CASCADE
			ON DELETE SET DEFAULT
	);

	CREATE TABLE corte_pelo(
	fecha_corte date CHECK(to_char(fecha_corte, 'YYYY') > '2017'),
	cod_cliente int NOT NULL, 
	cod_lugar int NOT NULL,
	nom_servicio varchar (50) NOT NULL,
	cod_producto int DEFAULT '000',
	CONSTRAINT PK_CORTE_PELO PRIMARY KEY (fecha_corte, cod_cliente, cod_lugar, nom_servicio),
	CONSTRAINT FK_CORTE_CLIENTE FOREIGN KEY (cod_cliente)
		REFERENCES cliente (cod_cliente),
	CONSTRAINT FK_CORTE_LUGAR FOREIGN KEY (cod_lugar)
		REFERENCES lugar (cod_lugar),
	CONSTRAINT FK_CORTE_SERVICIO FOREIGN KEY (nom_servicio)
		REFERENCES servicio (nom_servicio),
	CONSTRAINT FK_CORTE_PRODUCTO FOREIGN KEY (cod_producto)
		REFERENCES productos (cod_prod)
		ON UPDATE CASCADE
		ON DELETE SET DEFAULT
	);

	CREATE TABLE registro_multimedia(
	cod_registro SERIAL NOT NULL,
	num_fotos numeric(5) CHECK(num_fotos >= 0),
	num_videos numeric(5) CHECK(num_videos >= 0),
	fecha_registro date CHECK(to_char(fecha_registro, 'YYYY') > '2017'),
	cod_cliente int, 
	cod_lugar int,
	nom_servicio varchar(50),
	CONSTRAINT PK_REGISTRO_MULTIMEDIA PRIMARY KEY (cod_registro),
	CONSTRAINT FK_REGISTRO_MULTIMEDIA FOREIGN KEY (fecha_registro, cod_cliente, cod_lugar, nom_servicio)
		REFERENCES corte_pelo (fecha_corte, cod_cliente, cod_lugar, nom_servicio)
		ON UPDATE CASCADE
		ON DELETE SET NULL
	);

	CREATE TABLE gastar (
	fecha_corte date CHECK(to_char(fecha_corte, 'YYYY') > '2017'),
	cod_cliente int,
	cod_lugar int,
	cod_servicio varchar (50),
	cod_producto int DEFAULT '000',
	CONSTRAINT PK_GASTAR PRIMARY KEY (fecha_corte, cod_cliente, cod_lugar, cod_servicio, cod_producto),
	CONSTRAINT FK_GASTAR_CORTE FOREIGN KEY (fecha_corte, cod_cliente, cod_lugar, cod_servicio)
		REFERENCES corte_pelo (fecha_corte, cod_cliente, cod_lugar, nom_servicio)
		ON DELETE SET NULL
		ON UPDATE CASCADE,
	CONSTRAINT FK_GASTAR_PRODUCTO FOREIGN KEY (cod_producto)
		REFERENCES productos (cod_prod)
		ON DELETE SET DEFAULT
		ON UPDATE CASCADE
	);