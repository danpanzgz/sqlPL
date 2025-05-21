--FUNCIONES
--1

select * from tipo;

create or replace FUNCTION f_pokemon_getDebil(pid tipo.id_tipo%type)
return tipo.id_tipo%type
IS 
valor tipo.id_tipo%type;
BEGIN
    select esdebil into valor from tipo where id_tipo=pid;
    return valor;

END;
/
select f_pokemon_getDebil(id_tipo) as esdebil from tipo;

--2
create or replace function f_pokemon_getDefensa(pid mochila.id_mochila%type)
return mochila.id_mochila%type
is
valor mochila.id_mochila%type;
BEGIN
    select defensa into valor from mochila where id_mochila=pid;
    return valor;
END;
/
select f_pokemon_getDefensa(id_mochila) as defensa from mochila;

-- 3
create or replace function f_pokemon_getAtaque(pid mochila.ataque%type)
return mochila.ataque%type
is
valor mochila.ataque%type;
BEGIN
    select ataque into valor from mochila where id_mochila=pid;
    return valor;
END;
/
select f_pokemon_getAtaque(id_mochila) as ataque from mochila;
select * from mochila;


--4
create or replace function f_pokemon_getPuntos(pid mochila.puntos%type)
return mochila.puntos%type
is
valor mochila.puntos%type;
BEGIN
    select puntos into valor from mochila where id_mochila = pid;
    return valor;
END;
/
select f_pokemon_getPuntos(id_mochila) as puntos from mochila;


--PROCEDIMIENTOS
--5  Listar los pokemon de un usuario. El procedimiento recibe como argumento de entrada el usuario y la columna por la que quiere que se ordene de forma ascendente. 
--Mochila de USUARIO | ID | NOMBRE | TIPO | DEBIL | ATAQUE | DEFENSA | PESO | ALTURA | PUNTOS |


create or replace view lista_poke as
select 
    u.nom as USUARIO,
    p.pokedex as ID,
    p.nombre as NOMBRE,
    t.nombre as TIPO,
    t.esdebil as DEBIL,
    m.ataque as ATAQUE,
    m.defensa DEFENSA,
    m.peso as PESO,
    m.altura as ALTURA,
    m.puntos as PUNTOS
from mochila m
join usuario u on m.id_user =u.id_user
join pokemon p on m.id_poke = p.pokedex
join tipo t on p.id_tipo = t.id_tipo;
/
select * from lista_poke; 
select * from usuario;

create or replace procedure listar_poke(pnombre usuario.nom%type, columna number)
as
    v_count number;
BEGIN

    select count(*) into v_count
    from lista_poke
    where usuario = pnombre;

    if v_count = 0 then
        dbms_output.put_line('el usuario: "'||pnombre||'" no existe o no tiene pokémon.');
        return;
    end if;    

     dbms_output.put_line('|  id  |  nombre  |  tipo  |  debil  |  ataque  |  defensa  |  peso  |  altura  |  puntos  | Mochila de: ' || pnombre);

    if columna = 1 then
        for tupla in (select * from lista_poke where usuario = pnombre order by id) loop
            dbms_output.put_line('|     ' ||tupla.id || '   |    ' ||tupla.nombre|| '  |  ' ||tupla.tipo ||' |       ' ||tupla.debil || '      |      ' ||tupla.ataque || '          |      ' ||tupla.defensa || '           |        ' ||tupla.peso || '     |      ' ||tupla.altura || '      |        ' ||tupla.puntos|| '       |' );
        end loop;
    elsif columna = 2 then
        for tupla in (select * from lista_poke where usuario = pnombre order by nombre) loop
            dbms_output.put_line('|     ' ||tupla.id || '   |    ' ||tupla.nombre|| '  |  ' ||tupla.tipo ||' |       ' ||tupla.debil || '      |      ' ||tupla.ataque || '          |      ' ||tupla.defensa || '           |        ' ||tupla.peso || '     |      ' ||tupla.altura || '      |        ' ||tupla.puntos|| '       |' );
        end loop;
    elsif columna = 3 then
        for tupla in (select * from lista_poke where usuario = pnombre order by tipo) loop
            dbms_output.put_line('|     ' ||tupla.id || '   |    ' ||tupla.nombre|| '  |  ' ||tupla.tipo ||' |       ' ||tupla.debil || '      |      ' ||tupla.ataque || '          |      ' ||tupla.defensa || '           |        ' ||tupla.peso || '     |      ' ||tupla.altura || '      |        ' ||tupla.puntos|| '       |' );
        end loop;
    elsif columna = 4 then
        for tupla in (select * from lista_poke where usuario = pnombre order by debil) loop
            dbms_output.put_line('|     ' ||tupla.id || '   |    ' ||tupla.nombre|| '  |  ' ||tupla.tipo ||' |       ' ||tupla.debil || '      |      ' ||tupla.ataque || '          |      ' ||tupla.defensa || '           |        ' ||tupla.peso || '     |      ' ||tupla.altura || '      |        ' ||tupla.puntos|| '       |' );
        end loop;
    elsif columna = 5 then
        for tupla in (select * from lista_poke where usuario = pnombre order by ataque) loop
            dbms_output.put_line('|     ' ||tupla.id || '   |    ' ||tupla.nombre|| '  |  ' ||tupla.tipo ||' |       ' ||tupla.debil || '      |      ' ||tupla.ataque || '          |      ' ||tupla.defensa || '           |        ' ||tupla.peso || '     |      ' ||tupla.altura || '      |        ' ||tupla.puntos|| '       |' );
        end loop;
    elsif columna = 6 then
        for tupla in (select * from lista_poke where usuario = pnombre order by defensa) loop
            dbms_output.put_line('|     ' ||tupla.id || '   |    ' ||tupla.nombre|| '  |  ' ||tupla.tipo ||' |       ' ||tupla.debil || '      |      ' ||tupla.ataque || '          |      ' ||tupla.defensa || '           |        ' ||tupla.peso || '     |      ' ||tupla.altura || '      |        ' ||tupla.puntos|| '       |' );
        end loop;
    elsif columna = 7 then
        for tupla in (select * from lista_poke where usuario = pnombre order by peso) loop
            dbms_output.put_line('|     ' ||tupla.id || '   |    ' ||tupla.nombre|| '  |  ' ||tupla.tipo ||' |       ' ||tupla.debil || '      |      ' ||tupla.ataque || '          |      ' ||tupla.defensa || '           |        ' ||tupla.peso || '     |      ' ||tupla.altura || '      |        ' ||tupla.puntos|| '       |' );
        end loop;
    elsif columna = 8 then
        for tupla in (select * from lista_poke where usuario = pnombre order by altura) loop
            dbms_output.put_line('|     ' ||tupla.id || '   |    ' ||tupla.nombre|| '  |  ' ||tupla.tipo ||' |       ' ||tupla.debil || '      |      ' ||tupla.ataque || '          |      ' ||tupla.defensa || '           |        ' ||tupla.peso || '     |      ' ||tupla.altura || '      |        ' ||tupla.puntos|| '       |' );
        end loop;
    elsif columna = 9 then
        for tupla in (select * from lista_poke where usuario = pnombre order by puntos) loop
            dbms_output.put_line('|     ' ||tupla.id || '   |    ' ||tupla.nombre|| '  |  ' ||tupla.tipo ||' |       ' ||tupla.debil || '      |      ' ||tupla.ataque || '          |      ' ||tupla.defensa || '           |        ' ||tupla.peso || '     |      ' ||tupla.altura || '      |        ' ||tupla.puntos|| '       |' );
        end loop;
    else
        for tupla in (select * from lista_poke where usuario = pnombre order by id) loop
            dbms_output.put_line('|     ' ||tupla.id || '   |    ' ||tupla.nombre|| '  |  ' ||tupla.tipo ||' |       ' ||tupla.debil || '      |      ' ||tupla.ataque || '          |      ' ||tupla.defensa || '           |        ' ||tupla.peso || '     |      ' ||tupla.altura || '      |        ' ||tupla.puntos|| '       |' );
        end loop;
    end if;
end;
/
exec listar_poke('uno',3);

--6
--no lo entiendo


--7
create or replace procedure incr_victorias (pid mochila.id_mochila%type)
as
valor mochila.victorias%type;
BEGIN
    select victorias into valor from mochila where id_mochila =pid;
    valor := valor +1;
    update mochila set victorias = valor where id_mochila = pid;
    commit;
    
EXCEPTION
when NO_DATA_FOUND then
            dbms_output.put_line('No existe la mochila con ID ' || pid);
END;
/
select * from mochila;
exec incr_victorias(1);

--8
create or replace procedure borrar_poke (pid_mochila mochila.id_mochila%type, pid_user mochila.id_user%type )
as
BEGIN
    if pid_mochila is null then
        update mochila set id_poke = null, peso = 0, altura = 0, ataque = 0, defensa = 0, puntos = 0, victorias = 0
        where pid_user = pid_mochila;
    else
        update mochila SET id_poke = null, peso = 0, altura = 0, 
        ataque = 0, defensa = 0, puntos = 0, victorias = 0
        where pid_user = pid_mochila;
    end if;
END;

/
--DISPARADORES

--9
create or replace trigger nivel_poke
before update on mochila
for each row
begin
if :new.victorias = :old.victorias + 1 then
        :new.puntos  := :old.puntos  + 5;
        :new.ataque  := :old.ataque  + 1;
        :new.defensa := :old.defensa + 2;

    end if;
end;
/
--10

create or replace trigger borrar_pokemon
before delete on usuario
for each row
declare
cant number;
BEGIN
select count(*) into cant from mochila where mochila.id_user = :old.id_user and id_poke is not null;
if cant > 0 then
raise_application_error(-20002, 'No se puedo borrar a ' || :old.nom || ' porque tiene ' || cant || ' pokemones');
end if;
END;
/

--11
create or replace trigger demasiado_poke
before insert on mochila
for each row
declare
cant number;
BEGIN
select count(*) into cant from mochila where id_user = :new.id_user;
if cant >= 50 then
    raise_application_error(-20002, 'El usuario tiene demasiados pokemones');
end if;
END;
/

--12
create or replace trigger t_copa
after update on mochila
for each row
BEGIN
if mod(:new.victorias, 10) = 0
    and  mod(:old.victorias, 10) != 0
    THEN
        dbms_output.put_line('');
        dbms_output.put_line(' |        |');
        dbms_output.put_line('(| SFAfS  |)');
        dbms_output.put_line(' |  #X    | Enhorabuena!! Has conseguido 10 victorias más!!');
        dbms_output.put_line(' \       /');
        dbms_output.put_line('   `---´');
        dbms_output.put_line('   _|_|_');
end if;
END;
/
    
