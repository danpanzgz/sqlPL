
--Tablas
CREATE TABLE TIPO(id_tipo NUMBER(3),nombre VARCHAR2(15),esDebil NUMBER(3));
CREATE TABLE POKEMON(pokedex NUMBER(3),nombre VARCHAR2(15),id_tipo NUMBER(3));
CREATE TABLE USUARIO(id_user NUMBER(1),nom VARCHAR2(15),pas VARCHAR2(15));
CREATE TABLE MOCHILA(id_mochila NUMBER(5),id_user NUMBER(5),id_poke NUMBER(5),
    peso NUMBER(7,2) default 0, altura NUMBER(7,2) default 0, ataque NUMBER(7,2) default 0,
	defensa NUMBER(7,2) default 0, puntos NUMBER(7,2) default 0, victorias NUMBER(3) default 0);

--Claves Primarias
ALTER TABLE TIPO ADD CONSTRAINT tipo_pk PRIMARY KEY(id_tipo);
ALTER TABLE POKEMON ADD CONSTRAINT pokemon_pk PRIMARY KEY(pokedex);
ALTER TABLE USUARIO ADD CONSTRAINT usuario_pk PRIMARY KEY(id_user);
ALTER TABLE MOCHILA ADD CONSTRAINT mochila_pk PRIMARY KEY(id_mochila);

--Modificadores
ALTER TABLE TIPO MODIFY nombre NOT NULL;
ALTER TABLE POKEMON MODIFY nombre NOT NULL;
ALTER TABLE USUARIO MODIFY nom NOT NULL;
ALTER TABLE USUARIO MODIFY pas NOT NULL;
ALTER TABLE MOCHILA MODIFY peso NOT NULL;
ALTER TABLE MOCHILA MODIFY altura NOT NULL;
ALTER TABLE MOCHILA MODIFY ataque NOT NULL;
ALTER TABLE MOCHILA MODIFY defensa NOT NULL;

--Claves foraneas
--ALTER TABLE TIPO ADD CONSTRAINT tipo_fk1 FOREIGN KEY (esDebil) REFERENCES TIPO (id_tipo);
ALTER TABLE POKEMON ADD CONSTRAINT pokemon_fk1 FOREIGN KEY (id_tipo) REFERENCES TIPO (id_tipo);
ALTER TABLE MOCHILA ADD CONSTRAINT mochila_fk1 FOREIGN KEY (id_user) REFERENCES USUARIO (id_user);
ALTER TABLE MOCHILA ADD CONSTRAINT mochila_fk2 FOREIGN KEY (id_poke) REFERENCES POKEMON (pokedex);

CREATE or REPLACE TRIGGER valor_aleatorio
BEFORE INSERT ON MOCHILA
FOR EACH ROW
BEGIN
 :NEW.peso := trunc(DBMS_RANDOM.VALUE(10,60));
 :NEW.altura := trunc(DBMS_RANDOM.VALUE(50,200));
 :NEW.ataque := trunc(DBMS_RANDOM.VALUE(30,50));
 :NEW.defensa := trunc(DBMS_RANDOM.VALUE(40,60));
 :NEW.puntos := trunc(DBMS_RANDOM.VALUE(100,120)); 
END valor_aleatorio;
/


/*Tipos*/--FALTAN LAS DEBILIDADES++++++++++++++++++++++++++++
insert into TIPO values (1, 'Agua', 6);
insert into TIPO values (2, 'Bicho', 8);
insert into TIPO values (3, 'Dragón', 1);
insert into TIPO values (4, 'Eléctrico', 15);
insert into TIPO values (5, 'Fantasma', 2);
insert into TIPO values (6, 'Fuego', 7);
insert into TIPO values (7, 'Hielo', 12);
insert into TIPO values (8, 'Lucha', 14);
insert into TIPO values (9, 'Normal', 5);
insert into TIPO values (10, 'Planta', 2);
insert into TIPO values (11, 'Psíquico', 5);
insert into TIPO values (12, 'Roca', 8);
insert into TIPO values (13, 'Tierra', 10);
insert into TIPO values (14, 'Veneno', 11);
insert into TIPO values (15, 'Volador', 12);
insert into TIPO values (16, 'Hada', 4);

ALTER TABLE TIPO ADD CONSTRAINT tipo_fk1 FOREIGN KEY (esDebil) REFERENCES TIPO (id_tipo);

/*Pokemon*/
insert into POKEMON values (1, 'Bulbasaur', 10);
insert into POKEMON values (2, 'Ivysaur', 10);
insert into POKEMON values (3, 'Venasaur', 10);
insert into POKEMON values (4, 'Charmander', 6);
insert into POKEMON values (5, 'Charmeleon', 6);
insert into POKEMON values (6, 'Charizard', 6);
insert into POKEMON values (7, 'Squirtle', 1);
insert into POKEMON values (8, 'Wartortle', 1);
insert into POKEMON values (9, 'Blastoise', 1);
insert into POKEMON values (10, 'Caperpie', 2);
insert into POKEMON values (11, 'Metapod', 2);
insert into POKEMON values (12, 'Butterfree', 2);
insert into POKEMON values (13, 'Weedle', 2);
insert into POKEMON values (14, 'Kakuna', 2);
insert into POKEMON values (15, 'Beedrill', 2);
insert into POKEMON values (16, 'Pidgey', 9);
insert into POKEMON values (17, 'Pidgeotto', 9);
insert into POKEMON values (18, 'Pidgeot', 9);
insert into POKEMON values (19, 'Rattata', 9);
insert into POKEMON values (20, 'Raticate', 9);
insert into POKEMON values (21, 'Spearow', 9);
insert into POKEMON values(22, 'Fearow', 9);
insert into POKEMON values(23, 'Ekans', 14);
insert into POKEMON values(24, 'Arbok', 14);
insert into POKEMON values(25, 'Pikachu', 4);
insert into POKEMON values(26, 'Raichu', 4);
insert into POKEMON values(27, 'Sandshrew', 13);
insert into POKEMON values(28, 'Sandslash', 13);
insert into POKEMON values(29, 'Nidoran♀', 14);
insert into POKEMON values(30, 'Nidorina', 14);
insert into POKEMON values(31, 'Nidoqueen', 14);
insert into POKEMON values(32, 'Nidoran♂', 14);
insert into POKEMON values(33, 'Nidorino', 14);
insert into POKEMON values(34, 'Nidoking', 14);
insert into POKEMON values(35, 'Clefairy', 16);
insert into POKEMON values(36, 'Clefable', 16);
insert into POKEMON values(37, 'Vulpix', 6);
insert into POKEMON values(38, 'Ninetales', 6);
insert into POKEMON values(39, 'Jigglypuff', 9);
insert into POKEMON values(40, 'Wigglytuff', 9);
insert into POKEMON values(41, 'Zubat', 14);
insert into POKEMON values(42, 'Golbat', 14);
insert into POKEMON values(43, 'Oddish', 10);
insert into POKEMON values(44, 'Gloom', 10);
insert into POKEMON values(45, 'Vileplume', 10);
insert into POKEMON values(46, 'Paras', 2);
insert into POKEMON values(47, 'Parasect', 2);
insert into POKEMON values(48, 'Venonat', 2);
insert into POKEMON values(49, 'Venomoth', 2);
insert into POKEMON values(50, 'Diglett', 13);
insert into POKEMON values(51, 'Dugtrio', 13);
insert into POKEMON values(52, 'Meowth', 9);
insert into POKEMON values(53, 'Persian', 9);
insert into POKEMON values(54, 'Psyduck', 1);
insert into POKEMON values(55, 'Golduck', 1);
insert into POKEMON values(56, 'Mankey', 8);
insert into POKEMON values(57, 'Primeape', 8);
insert into POKEMON values(58, 'Growlithe', 6);
insert into POKEMON values(59, 'Arcanine', 6);
insert into POKEMON values(60, 'Poliwag', 1);
insert into POKEMON values(61, 'Poliwhirl', 1);
insert into POKEMON values(62, 'Poliwrath', 1);
insert into POKEMON values(63, 'Abra', 11);
insert into POKEMON values(64, 'Kadabra', 11);
insert into POKEMON values(65, 'Alakazam', 11);
insert into POKEMON values(66, 'Machop', 8);
insert into POKEMON values(67, 'Machoke', 8);
insert into POKEMON values(68, 'Machamp', 8);
insert into POKEMON values(69, 'Bellsprout', 10);
insert into POKEMON values(70, 'Weepinbell', 10);
insert into POKEMON values(71, 'Victreebel', 10);
insert into POKEMON values(72, 'Tentacool', 1);
insert into POKEMON values(73, 'Tentacruel', 1);
insert into POKEMON values(74, 'Geodude', 12);
insert into POKEMON values(75, 'Graveler', 12);
insert into POKEMON values(76, 'Golem', 12);
insert into POKEMON values(77, 'Ponyta', 6);
insert into POKEMON values(78, 'Rapidash', 6);
insert into POKEMON values(79, 'Slowpoke', 1);
insert into POKEMON values(80, 'Slowbro', 1);
insert into POKEMON values(81, 'Magnemite', 4);
insert into POKEMON values(82, 'Magneton', 4);
insert into POKEMON values(83, 'Farfetch’d', 9);
insert into POKEMON values(84, 'Doduo', 9);
insert into POKEMON values(85, 'Dodrio', 9);
insert into POKEMON values(86, 'Seel', 1);
insert into POKEMON values(87, 'Dewgong', 1);
insert into POKEMON values(88, 'Grimer', 14);
insert into POKEMON values(89, 'Muk', 14);
insert into POKEMON values(90, 'Shellder', 1);
insert into POKEMON values(91, 'Cloyster', 1);
insert into POKEMON values(92, 'Gastly', 5);
insert into POKEMON values(93, 'Haunter', 5);
insert into POKEMON values(94, 'Gengar', 5);
insert into POKEMON values(95, 'Onix', 12);
insert into POKEMON values(96, 'Drowzee', 11);
insert into POKEMON values(97, 'Hypno', 11);
insert into POKEMON values(98, 'Krabby', 1);
insert into POKEMON values(99, 'Kingler', 1);
insert into POKEMON values(100, 'Voltorb', 4);
insert into POKEMON values(101, 'Electrode', 4);
insert into POKEMON values(102, 'Exeggcute', 10);
insert into POKEMON values(103, 'Exeggutor', 10);
insert into POKEMON values(104, 'Cubone', 13);
insert into POKEMON values(105, 'Marowak', 13);
insert into POKEMON values(106, 'Hitmonlee', 8);
insert into POKEMON values(107, 'Hitmonchan', 8);
insert into POKEMON values(108, 'Lickitung', 9);
insert into POKEMON values(109, 'Koffing', 14);
insert into POKEMON values(110, 'Weezing', 14);
insert into POKEMON values(111, 'Rhyhorn', 13);
insert into POKEMON values(112, 'Rhydon', 13);
insert into POKEMON values(113, 'Chansey', 9);
insert into POKEMON values(114, 'Tangela', 10);
insert into POKEMON values(115, 'Kangaskhan', 9);
insert into POKEMON values(116, 'Horsea', 1);
insert into POKEMON values(117, 'Seadra', 1);
insert into POKEMON values(118, 'Goldeen', 1);
insert into POKEMON values(119, 'Seaking', 1);
insert into POKEMON values(120, 'Staryu', 1);
insert into POKEMON values(121, 'Starmie', 1);
insert into POKEMON values(122, 'Mr. Mime', 11);
insert into POKEMON values(123, 'Scyther', 2);
insert into POKEMON values(124, 'Jynx', 7);
insert into POKEMON values(125, 'Electabuzz', 4);
insert into POKEMON values(126, 'Magmar', 6);
insert into POKEMON values(127, 'Pinsir', 2);
insert into POKEMON values(128, 'Tauros', 9);
insert into POKEMON values(129, 'Magikarp', 1);
insert into POKEMON values(130, 'Gyarados', 1);
insert into POKEMON values(131, 'Lapras', 1);
insert into POKEMON values(132, 'Ditto', 9);
insert into POKEMON values(133, 'Eevee', 9);
insert into POKEMON values(134, 'Vaporeon', 1);
insert into POKEMON values(135, 'Jolteon', 4);
insert into POKEMON values(136, 'Flareon', 6);
insert into POKEMON values(137, 'Porygon', 9);
insert into POKEMON values(138, 'Omanyte', 12);
insert into POKEMON values(139, 'Omastar', 12);
insert into POKEMON values(140, 'Kabuto', 12);
insert into POKEMON values(141, 'Kabutops', 12);
insert into POKEMON values(142, 'Aerodactyl', 12);
insert into POKEMON values(143, 'Snorlax', 9);
insert into POKEMON values(144, 'Articuno', 7);
insert into POKEMON values(145, 'Zapdos', 4);
insert into POKEMON values(146, 'Moltres', 6);
insert into POKEMON values(147, 'Dratini', 3);
insert into POKEMON values(148, 'Dragonair', 3);
insert into POKEMON values(149, 'Dragonite', 3);
insert into POKEMON values(150, 'Mewtwo', 11);
insert into POKEMON values(151, 'Mew', 11);

---otras inserciones
insert into USUARIO values(1,'uno','dos');

insert into mochila(id_mochila, id_user, id_poke) VALUES (1,1,1); 

select * from mochila;