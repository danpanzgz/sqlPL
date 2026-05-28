# Soluciones PL/SQL — Todos los ejercicios
**DAW1 – Bases de datos**

---

## BLOQUE 5 — Variables, Registros, Procedimientos y Funciones

### Bloque 1 — Registros

#### Ejercicio 1 — Datos completos de un usuario

```sql
DECLARE
    r_usuario USUARIOS%ROWTYPE;
BEGIN
    SELECT * INTO r_usuario
    FROM USUARIOS
    WHERE ID_USUARIO = 4;

    DBMS_OUTPUT.PUT_LINE('Nombre : ' || r_usuario.NOMBRE);
    DBMS_OUTPUT.PUT_LINE('Email  : ' || r_usuario.EMAIL);
    DBMS_OUTPUT.PUT_LINE('Ciudad : ' || r_usuario.CIUDAD);
    DBMS_OUTPUT.PUT_LINE('Edad   : ' || r_usuario.EDAD || ' anios');
    DBMS_OUTPUT.PUT_LINE('Activo : ' || CASE r_usuario.ACTIVO WHEN 'S' THEN 'Si' ELSE 'No' END);
END;
/
```

#### Ejercicio 2 — Resumen de producto con nivel de stock

```sql
DECLARE
    TYPE t_resumen_producto IS RECORD (
        nombre      VARCHAR2(100),
        precio      NUMBER,
        nivel_stock VARCHAR2(20)
    );
    r_prod t_resumen_producto;
    v_stock PRODUCTOS.STOCK%TYPE;
BEGIN
    SELECT NOMBRE, PRECIO, STOCK
    INTO r_prod.nombre, r_prod.precio, v_stock
    FROM PRODUCTOS
    WHERE ID_PRODUCTO = 5;

    r_prod.nivel_stock := CASE
        WHEN v_stock = 0  THEN 'Sin stock'
        WHEN v_stock <= 5 THEN 'Bajo'
        ELSE 'Suficiente'
    END;

    DBMS_OUTPUT.PUT_LINE('Nombre      : ' || r_prod.nombre);
    DBMS_OUTPUT.PUT_LINE('Precio      : ' || r_prod.precio || ' EUR');
    DBMS_OUTPUT.PUT_LINE('Nivel stock : ' || r_prod.nivel_stock);
END;
/
```

#### Ejercicio 3 — Recorrer pedidos de un usuario con FOR

```sql
BEGIN
    DBMS_OUTPUT.PUT_LINE('Pedidos del usuario #1:');
    FOR r IN (
        SELECT pe.ID_PEDIDO,
               pr.NOMBRE   AS PRODUCTO,
               pe.CANTIDAD * pr.PRECIO AS IMPORTE,
               pe.ESTADO
        FROM   PEDIDOS pe
        JOIN   PRODUCTOS pr ON pe.ID_PRODUCTO = pr.ID_PRODUCTO
        WHERE  pe.ID_USUARIO = 1
        ORDER  BY pe.ID_PEDIDO
    ) LOOP
        DBMS_OUTPUT.PUT_LINE(
            '  Pedido #' || r.ID_PEDIDO ||
            ' | ' || RPAD(r.PRODUCTO, 20) ||
            ' | ' || r.IMPORTE || ' EUR' ||
            ' | ' || r.ESTADO
        );
    END LOOP;
END;
/
```

#### Ejercicio 4 — Pedido de mayor importe con TYPE...RECORD

```sql
DECLARE
    TYPE t_top_pedido IS RECORD (
        id_pedido       NUMBER,
        nombre_cliente  VARCHAR2(50),
        nombre_producto VARCHAR2(100),
        importe         NUMBER
    );
    r_top t_top_pedido;
BEGIN
    SELECT pe.ID_PEDIDO, u.NOMBRE, pr.NOMBRE,
           pe.CANTIDAD * pr.PRECIO
    INTO   r_top.id_pedido, r_top.nombre_cliente,
           r_top.nombre_producto, r_top.importe
    FROM   PEDIDOS pe
    JOIN   USUARIOS  u  ON pe.ID_USUARIO  = u.ID_USUARIO
    JOIN   PRODUCTOS pr ON pe.ID_PRODUCTO = pr.ID_PRODUCTO
    ORDER  BY pe.CANTIDAD * pr.PRECIO DESC
    FETCH  FIRST 1 ROW ONLY;

    DBMS_OUTPUT.PUT_LINE('=== Pedido de mayor importe ===');
    DBMS_OUTPUT.PUT_LINE('Pedido  : #' || r_top.id_pedido);
    DBMS_OUTPUT.PUT_LINE('Cliente : '  || r_top.nombre_cliente);
    DBMS_OUTPUT.PUT_LINE('Producto: '  || r_top.nombre_producto);
    DBMS_OUTPUT.PUT_LINE('Importe : '  || r_top.importe || ' EUR');
END;
/
```

---

### Bloque 2 — Procedimientos

#### Ejercicio 1 — Mostrar todos los pedidos de un usuario

```sql
CREATE OR REPLACE PROCEDURE pedidos_de_usuario (p_id IN NUMBER)
IS
    v_count NUMBER := 0;
BEGIN
    FOR r IN (
        SELECT pe.ID_PEDIDO, pr.NOMBRE AS PRODUCTO, pe.ESTADO
        FROM   PEDIDOS pe
        JOIN   PRODUCTOS pr ON pe.ID_PRODUCTO = pr.ID_PRODUCTO
        WHERE  pe.ID_USUARIO = p_id
        ORDER  BY pe.ID_PEDIDO
    ) LOOP
        IF v_count = 0 THEN
            DBMS_OUTPUT.PUT_LINE('--- Pedidos usuario #' || p_id || ' ---');
        END IF;
        DBMS_OUTPUT.PUT_LINE(
            '  #' || r.ID_PEDIDO ||
            ' | ' || RPAD(r.PRODUCTO, 22) ||
            ' | ' || r.ESTADO
        );
        v_count := v_count + 1;
    END LOOP;

    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Este usuario no tiene pedidos registrados.');
    END IF;
END pedidos_de_usuario;
/

-- Llamadas de prueba
BEGIN
    pedidos_de_usuario(1);
    pedidos_de_usuario(3);
END;
/
```

#### Ejercicio 2 — Calcular el total gastado por un usuario

```sql
CREATE OR REPLACE PROCEDURE total_gastado
    (p_id    IN  NUMBER,
     p_total OUT NUMBER)
IS
BEGIN
    SELECT NVL(SUM(pe.CANTIDAD * pr.PRECIO), 0)
    INTO   p_total
    FROM   PEDIDOS pe
    JOIN   PRODUCTOS pr ON pe.ID_PRODUCTO = pr.ID_PRODUCTO
    WHERE  pe.ID_USUARIO = p_id;
END total_gastado;
/

-- Llamada
DECLARE
    v_total NUMBER;
BEGIN
    total_gastado(1, v_total);
    DBMS_OUTPUT.PUT_LINE('Total gastado usuario #1: ' || v_total || ' EUR');
END;
/
```

#### Ejercicio 3 — Reducir el stock de un producto

```sql
CREATE OR REPLACE PROCEDURE reducir_stock
    (p_id_producto IN NUMBER,
     p_cantidad    IN NUMBER)
IS
    v_stock    PRODUCTOS.STOCK%TYPE;
    v_nombre   PRODUCTOS.NOMBRE%TYPE;
BEGIN
    SELECT NOMBRE, STOCK
    INTO   v_nombre, v_stock
    FROM   PRODUCTOS
    WHERE  ID_PRODUCTO = p_id_producto;

    IF (v_stock - p_cantidad) < 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            'Error: stock insuficiente. Stock actual: ' || v_stock || ' unidades.'
        );
    ELSE
        UPDATE PRODUCTOS
        SET    STOCK = STOCK - p_cantidad
        WHERE  ID_PRODUCTO = p_id_producto;

        DBMS_OUTPUT.PUT_LINE(
            'Stock actualizado. Nuevo stock: ' || (v_stock - p_cantidad) || ' unidades.'
        );
    END IF;
END reducir_stock;
/

-- Prueba
BEGIN
    reducir_stock(4, 5);
    ROLLBACK;
END;
/
```

#### Ejercicio 4 — Aplicar descuento a un precio

```sql
CREATE OR REPLACE PROCEDURE aplicar_descuento
    (p_precio     IN OUT NUMBER,
     p_descuento  IN     NUMBER)
IS
BEGIN
    p_precio := ROUND(p_precio - p_precio * p_descuento / 100, 2);
END aplicar_descuento;
/

-- Llamada
DECLARE
    v_precio     NUMBER := 349.50;
    v_descuento  NUMBER := 10;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Precio original : ' || v_precio || ' EUR');
    aplicar_descuento(v_precio, v_descuento);
    DBMS_OUTPUT.PUT_LINE('Precio con ' || v_descuento || '% dto: ' || v_precio || ' EUR');
END;
/
```

---

### Bloque 3 — Funciones

#### Ejercicio 1 — Función que devuelve el nombre de un usuario

```sql
CREATE OR REPLACE FUNCTION nombre_usuario (p_id IN NUMBER)
RETURN VARCHAR2
IS
    v_nombre USUARIOS.NOMBRE%TYPE;
BEGIN
    SELECT NOMBRE INTO v_nombre
    FROM   USUARIOS
    WHERE  ID_USUARIO = p_id;

    RETURN v_nombre;
EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN 'Usuario desconocido';
END nombre_usuario;
/

-- Llamada
BEGIN
    DBMS_OUTPUT.PUT_LINE('ID  5 : ' || nombre_usuario(5));
    DBMS_OUTPUT.PUT_LINE('ID 99 : ' || nombre_usuario(99));
END;
/
```

#### Ejercicio 2 — Función que cuenta pedidos por estado

```sql
CREATE OR REPLACE FUNCTION contar_por_estado (p_estado IN VARCHAR2)
RETURN NUMBER
IS
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM   PEDIDOS
    WHERE  ESTADO = p_estado;

    RETURN v_total;
END contar_por_estado;
/

-- Llamada
BEGIN
    DBMS_OUTPUT.PUT_LINE('PENDIENTE  : ' || contar_por_estado('PENDIENTE'));
    DBMS_OUTPUT.PUT_LINE('ENVIADO    : ' || contar_por_estado('ENVIADO'));
    DBMS_OUTPUT.PUT_LINE('ENTREGADO  : ' || contar_por_estado('ENTREGADO'));
    DBMS_OUTPUT.PUT_LINE('CANCELADO  : ' || contar_por_estado('CANCELADO'));
END;
/
```

#### Ejercicio 3 — Función precio con IVA usada en SELECT

```sql
CREATE OR REPLACE FUNCTION precio_con_iva (p_precio IN NUMBER)
RETURN NUMBER
IS
BEGIN
    RETURN ROUND(p_precio * 1.21, 2);
END precio_con_iva;
/

-- Uso en SELECT
SELECT NOMBRE,
       PRECIO          AS PRECIO_SIN_IVA,
       precio_con_iva(PRECIO) AS PRECIO_CON_IVA
FROM   PRODUCTOS
ORDER  BY PRECIO DESC;
```

#### Ejercicio 4 — Función que devuelve la ciudad con más pedidos

```sql
CREATE OR REPLACE FUNCTION ciudad_mas_pedidos
RETURN VARCHAR2
IS
    v_ciudad USUARIOS.CIUDAD%TYPE;
BEGIN
    SELECT u.CIUDAD
    INTO   v_ciudad
    FROM   PEDIDOS pe
    JOIN   USUARIOS u ON pe.ID_USUARIO = u.ID_USUARIO
    GROUP  BY u.CIUDAD
    ORDER  BY COUNT(*) DESC
    FETCH  FIRST 1 ROW ONLY;

    RETURN v_ciudad;
END ciudad_mas_pedidos;
/

-- Llamada
BEGIN
    DBMS_OUTPUT.PUT_LINE('Ciudad con mas pedidos: ' || ciudad_mas_pedidos);
END;
/
```

---

## BLOQUE 6 — Excepciones

#### Ejercicio 1 — Capturar errores al consultar PRODUCTOS y PEDIDOS

```sql
DECLARE
    v_nombre   PRODUCTOS.NOMBRE%TYPE;
    v_id_ped   PEDIDOS.ID_PEDIDO%TYPE;
    v_num      NUMBER;
BEGIN
    -- Prueba 1: NO_DATA_FOUND
    BEGIN
        SELECT NOMBRE INTO v_nombre
        FROM   PRODUCTOS WHERE ID_PRODUCTO = 50;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('ERROR 1 [NO_DATA_FOUND]: No existe el producto con ID 50.');
    END;

    -- Prueba 2: TOO_MANY_ROWS
    BEGIN
        SELECT ID_PEDIDO INTO v_id_ped FROM PEDIDOS;
    EXCEPTION
        WHEN TOO_MANY_ROWS THEN
            SELECT COUNT(*) INTO v_num FROM PEDIDOS;
            DBMS_OUTPUT.PUT_LINE('ERROR 2 [TOO_MANY_ROWS]: Hay ' || v_num || ' pedidos en total.');
    END;

    -- Prueba 3: VALUE_ERROR
    BEGIN
        v_num := TO_NUMBER('ABCDE');
    EXCEPTION
        WHEN VALUE_ERROR THEN
            DBMS_OUTPUT.PUT_LINE('ERROR 3 [VALUE_ERROR]:');
            DBMS_OUTPUT.PUT_LINE('  SQLCODE : ' || SQLCODE);
            DBMS_OUTPUT.PUT_LINE('  SQLERRM : ' || SQLERRM);
    END;

    DBMS_OUTPUT.PUT_LINE('Todos los errores han sido gestionados correctamente.');
END;
/
```

#### Ejercicio 2 — Validar inserción de usuario con excepción de usuario

```sql
CREATE OR REPLACE PROCEDURE insertar_usuario
    (p_nombre VARCHAR2,
     p_email  VARCHAR2,
     p_edad   NUMBER)
IS
    e_edad_invalida  EXCEPTION;
    e_nombre_vacio   EXCEPTION;
    v_nuevo_id NUMBER;
BEGIN
    IF p_edad < 16 THEN
        RAISE e_edad_invalida;
    END IF;

    IF p_nombre IS NULL OR TRIM(p_nombre) = '' THEN
        RAISE e_nombre_vacio;
    END IF;

    SELECT NVL(MAX(ID_USUARIO), 0) + 1 INTO v_nuevo_id FROM USUARIOS;

    INSERT INTO USUARIOS (ID_USUARIO, NOMBRE, EMAIL, EDAD, ACTIVO)
    VALUES (v_nuevo_id, p_nombre, p_email, p_edad, 'S');

    DBMS_OUTPUT.PUT_LINE('Usuario insertado correctamente. ID asignado: ' || v_nuevo_id);

EXCEPTION
    WHEN e_edad_invalida THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: Edad invalida (' || p_edad || '). Minimo 16 anios.');
    WHEN e_nombre_vacio THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: El nombre no puede estar vacio.');
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('ERROR: El email ya existe en la base de datos.');
END insertar_usuario;
/

-- Pruebas
BEGIN
    insertar_usuario('Ana Menor', 'ana@mail.com', 14);
    insertar_usuario(NULL, 'vacio@mail.com', 25);
    insertar_usuario('Carmen Gil', 'carmen@mail.com', 30);
    ROLLBACK;
END;
/
```

#### Ejercicio 3 — Procedimiento con RAISE_APPLICATION_ERROR para gestionar stock

```sql
CREATE OR REPLACE PROCEDURE procesar_pedido
    (p_id_producto IN NUMBER,
     p_cantidad    IN NUMBER)
IS
    v_nombre PRODUCTOS.NOMBRE%TYPE;
    v_precio PRODUCTOS.PRECIO%TYPE;
    v_stock  PRODUCTOS.STOCK%TYPE;
BEGIN
    BEGIN
        SELECT NOMBRE, PRECIO, STOCK
        INTO   v_nombre, v_precio, v_stock
        FROM   PRODUCTOS
        WHERE  ID_PRODUCTO = p_id_producto;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001,
                'Producto no encontrado: ID ' || p_id_producto);
    END;

    IF p_cantidad <= 0 THEN
        RAISE_APPLICATION_ERROR(-20002,
            'La cantidad debe ser un numero positivo');
    END IF;

    IF v_stock < p_cantidad THEN
        RAISE_APPLICATION_ERROR(-20003,
            'Stock insuficiente. Disponible: ' || v_stock || ' unidades');
    END IF;

    DBMS_OUTPUT.PUT_LINE(
        'Pedido OK: ' || p_cantidad || ' x ' || v_nombre ||
        ' = ' || ROUND(p_cantidad * v_precio, 2) || ' EUR'
    );

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('SQLCODE : ' || SQLCODE);
        DBMS_OUTPUT.PUT_LINE('SQLERRM : ' || SQLERRM);
END procesar_pedido;
/

-- Pruebas
BEGIN
    procesar_pedido(99, 1);
    procesar_pedido(4, -1);
    procesar_pedido(4, 100);
    procesar_pedido(2, 3);
END;
/
```

#### Ejercicio 4 — Gestor de errores completo con PRAGMA EXCEPTION_INIT

```sql
DECLARE
    e_fk_error    EXCEPTION;
    e_check_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_fk_error,    -2291);
    PRAGMA EXCEPTION_INIT(e_check_error, -2290);
BEGIN
    -- Intento 1: clave foranea inexistente
    BEGIN
        INSERT INTO PEDIDOS (ID_PEDIDO, ID_USUARIO, ID_PRODUCTO, CANTIDAD, ESTADO)
        VALUES (998, 999, 1, 1, 'PENDIENTE');
    EXCEPTION
        WHEN e_fk_error THEN
            DBMS_OUTPUT.PUT_LINE('ERROR FK: El usuario o producto referenciado no existe.');
            DBMS_OUTPUT.PUT_LINE('  SQLCODE: ' || SQLCODE);
    END;

    -- Intento 2: cantidad negativa (viola CHECK)
    BEGIN
        INSERT INTO PEDIDOS (ID_PEDIDO, ID_USUARIO, ID_PRODUCTO, CANTIDAD, ESTADO)
        VALUES (999, 1, 1, -5, 'PENDIENTE');
    EXCEPTION
        WHEN e_check_error THEN
            DBMS_OUTPUT.PUT_LINE('ERROR CHECK: La cantidad no puede ser negativa.');
            DBMS_OUTPUT.PUT_LINE('  SQLCODE: ' || SQLCODE);
    END;

    -- Intento 3: pedido correcto
    BEGIN
        INSERT INTO PEDIDOS (ID_PEDIDO, ID_USUARIO, ID_PRODUCTO, CANTIDAD, ESTADO)
        VALUES (997, 1, 2, 1, 'PENDIENTE');
        DBMS_OUTPUT.PUT_LINE('Pedido insertado correctamente.');
    END;

    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('ROLLBACK realizado. Datos sin cambios.');
END;
/
```

---

## BLOQUE 7 — Cursores

### Cursores implícitos

#### Ejercicio 1 — Consultar datos de un producto

```sql
DECLARE
    v_nombre PRODUCTOS.NOMBRE%TYPE;
    v_precio PRODUCTOS.PRECIO%TYPE;
    v_stock  PRODUCTOS.STOCK%TYPE;
BEGIN
    SELECT NOMBRE, PRECIO, STOCK
    INTO   v_nombre, v_precio, v_stock
    FROM   PRODUCTOS
    WHERE  ID_PRODUCTO = 8;

    DBMS_OUTPUT.PUT_LINE('Nombre : ' || v_nombre);
    DBMS_OUTPUT.PUT_LINE('Precio : ' || v_precio || ' EUR');
    DBMS_OUTPUT.PUT_LINE('Stock  : ' || v_stock  || ' unidades');

    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Producto encontrado correctamente.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No existe el producto con ID 8.');
END;
/
```

#### Ejercicio 2 — Actualizar precio y contar filas

```sql
BEGIN
    UPDATE PRODUCTOS
    SET    PRECIO = PRECIO * 1.05
    WHERE  CATEGORIA = 'Informatica';

    IF SQL%FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Productos actualizados: ' || SQL%ROWCOUNT);
    ELSE
        DBMS_OUTPUT.PUT_LINE('AVISO: No se actualizo ningun producto de esa categoria.');
    END IF;

    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('ROLLBACK realizado.');
END;
/
```

#### Ejercicio 3 — Verificar si un usuario tiene pedidos

```sql
DECLARE
    v_id_ped PEDIDOS.ID_PEDIDO%TYPE;
    v_count  NUMBER;
BEGIN
    -- Usuario 8 (sin pedidos)
    BEGIN
        SELECT ID_PEDIDO INTO v_id_ped
        FROM   PEDIDOS WHERE ID_USUARIO = 8;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Usuario 8: no tiene pedidos registrados.');
        WHEN TOO_MANY_ROWS THEN
            SELECT COUNT(*) INTO v_count FROM PEDIDOS WHERE ID_USUARIO = 8;
            DBMS_OUTPUT.PUT_LINE('Usuario 8: tiene ' || v_count || ' pedidos (TOO_MANY_ROWS).');
    END;

    -- Usuario 1 (con varios pedidos)
    BEGIN
        SELECT ID_PEDIDO INTO v_id_ped
        FROM   PEDIDOS WHERE ID_USUARIO = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Usuario 1: no tiene pedidos registrados.');
        WHEN TOO_MANY_ROWS THEN
            SELECT COUNT(*) INTO v_count FROM PEDIDOS WHERE ID_USUARIO = 1;
            DBMS_OUTPUT.PUT_LINE('Usuario 1: tiene ' || v_count || ' pedidos (TOO_MANY_ROWS).');
    END;
END;
/
```

#### Ejercicio 4 — Borrar pedidos cancelados

```sql
BEGIN
    DELETE FROM PEDIDOS WHERE ESTADO = 'CANCELADO';

    IF SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('No habia pedidos cancelados que borrar.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Pedidos cancelados borrados: ' || SQL%ROWCOUNT);
    END IF;

    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('ROLLBACK realizado. Datos sin cambios.');
END;
/
```

---

### Cursores explícitos

#### Ejercicio 1 — Recorrer todos los usuarios con OPEN/FETCH/CLOSE

```sql
DECLARE
    CURSOR c_usuarios IS
        SELECT ID_USUARIO, NOMBRE, ACTIVO
        FROM   USUARIOS
        ORDER  BY ID_USUARIO;
    v_fila c_usuarios%ROWTYPE;
BEGIN
    OPEN c_usuarios;
    LOOP
        FETCH c_usuarios INTO v_fila;
        EXIT WHEN c_usuarios%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            'ID: ' || LPAD(v_fila.ID_USUARIO, 3, '0') ||
            ' | ' || RPAD(v_fila.NOMBRE, 18) ||
            ' | Activo: ' || CASE v_fila.ACTIVO WHEN 'S' THEN 'Si' ELSE 'No' END
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Total leidos: ' || c_usuarios%ROWCOUNT || ' usuarios.');
    CLOSE c_usuarios;
END;
/
```

#### Ejercicio 2 — Cursor con parámetro para buscar pedidos por estado

```sql
DECLARE
    CURSOR c_por_estado (p_estado VARCHAR2) IS
        SELECT pe.ID_PEDIDO,
               u.NOMBRE  AS USUARIO,
               pr.NOMBRE AS PRODUCTO
        FROM   PEDIDOS pe
        JOIN   USUARIOS  u  ON pe.ID_USUARIO  = u.ID_USUARIO
        JOIN   PRODUCTOS pr ON pe.ID_PRODUCTO = pr.ID_PRODUCTO
        WHERE  pe.ESTADO = p_estado
        ORDER  BY pe.ID_PEDIDO;
    v_fila c_por_estado%ROWTYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== Pedidos ENTREGADOS ===');
    OPEN c_por_estado('ENTREGADO');
    LOOP
        FETCH c_por_estado INTO v_fila;
        EXIT WHEN c_por_estado%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            '  #' || v_fila.ID_PEDIDO ||
            ' | ' || RPAD(v_fila.USUARIO, 14) ||
            ' | ' || v_fila.PRODUCTO
        );
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Total: ' || c_por_estado%ROWCOUNT || ' pedidos entregados.');
    CLOSE c_por_estado;
END;
/
```

#### Ejercicio 3 — Cursor que se detiene al encontrar producto sin stock

```sql
DECLARE
    CURSOR c_stock IS
        SELECT ID_PRODUCTO, NOMBRE, STOCK
        FROM   PRODUCTOS
        ORDER  BY ID_PRODUCTO;
    v_fila      c_stock%ROWTYPE;
    v_encontrado BOOLEAN := FALSE;
BEGIN
    OPEN c_stock;
    LOOP
        FETCH c_stock INTO v_fila;
        EXIT WHEN c_stock%NOTFOUND;
        IF v_fila.STOCK = 0 THEN
            v_encontrado := TRUE;
            DBMS_OUTPUT.PUT_LINE('Primer producto sin stock encontrado:');
            DBMS_OUTPUT.PUT_LINE('  ID: ' || v_fila.ID_PRODUCTO || ' | ' || v_fila.NOMBRE);
            EXIT;
        END IF;
    END LOOP;

    IF NOT v_encontrado THEN
        DBMS_OUTPUT.PUT_LINE('Todos los productos tienen stock.');
    END IF;

    CLOSE c_stock;
END;
/
```

#### Ejercicio 4 — Cursores anidados: usuarios y sus pedidos

```sql
DECLARE
    CURSOR c_usuarios IS
        SELECT DISTINCT u.ID_USUARIO, u.NOMBRE
        FROM   USUARIOS u
        JOIN   PEDIDOS  p ON u.ID_USUARIO = p.ID_USUARIO
        ORDER  BY u.ID_USUARIO;

    CURSOR c_pedidos (p_id NUMBER) IS
        SELECT pe.ID_PEDIDO,
               pr.NOMBRE AS PRODUCTO,
               pe.CANTIDAD * pr.PRECIO AS IMPORTE,
               pe.ESTADO
        FROM   PEDIDOS pe
        JOIN   PRODUCTOS pr ON pe.ID_PRODUCTO = pr.ID_PRODUCTO
        WHERE  pe.ID_USUARIO = p_id
        ORDER  BY pe.ID_PEDIDO;

    v_usr c_usuarios%ROWTYPE;
    v_ped c_pedidos%ROWTYPE;
BEGIN
    OPEN c_usuarios;
    LOOP
        FETCH c_usuarios INTO v_usr;
        EXIT WHEN c_usuarios%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('USUARIO: ' || v_usr.NOMBRE);

        OPEN c_pedidos(v_usr.ID_USUARIO);
        LOOP
            FETCH c_pedidos INTO v_ped;
            EXIT WHEN c_pedidos%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(
                '  #' || v_ped.ID_PEDIDO ||
                ' | ' || RPAD(v_ped.PRODUCTO, 22) ||
                ' | ' || LPAD(v_ped.IMPORTE, 10) || ' EUR' ||
                ' | ' || v_ped.ESTADO
            );
        END LOOP;
        CLOSE c_pedidos;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------');
    CLOSE c_usuarios;
END;
/
```

---

### Atributos de cursor

#### Ejercicio 1 — Usar %ISOPEN para apertura y cierre seguros

```sql
DECLARE
    CURSOR c_productos IS SELECT NOMBRE FROM PRODUCTOS ORDER BY ID_PRODUCTO;
    v_nombre PRODUCTOS.NOMBRE%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('%ISOPEN antes de OPEN: ' ||
        CASE WHEN c_productos%ISOPEN THEN 'SI' ELSE 'NO' END);

    OPEN c_productos;

    DBMS_OUTPUT.PUT_LINE('%ISOPEN tras OPEN   : ' ||
        CASE WHEN c_productos%ISOPEN THEN 'SI' ELSE 'NO' END);

    FOR i IN 1..3 LOOP
        FETCH c_productos INTO v_nombre;
        EXIT WHEN c_productos%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('  Leido: ' || v_nombre);
    END LOOP;

    IF c_productos%ISOPEN THEN
        CLOSE c_productos;
        DBMS_OUTPUT.PUT_LINE('Cursor cerrado correctamente.');
    END IF;
END;
/
```

#### Ejercicio 2 — Contar filas leídas con %ROWCOUNT

```sql
DECLARE
    CURSOR c_pedidos IS SELECT ID_PEDIDO FROM PEDIDOS ORDER BY ID_PEDIDO;
    v_id PEDIDOS.ID_PEDIDO%TYPE;
BEGIN
    OPEN c_pedidos;
    LOOP
        FETCH c_pedidos INTO v_id;
        EXIT WHEN c_pedidos%NOTFOUND;
        IF MOD(c_pedidos%ROWCOUNT, 3) = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Llevan leidos ' || c_pedidos%ROWCOUNT || ' pedidos...');
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Total pedidos leidos: ' || c_pedidos%ROWCOUNT);
    CLOSE c_pedidos;
END;
/
```

#### Ejercicio 3 — Salir del bucle con %FOUND y %NOTFOUND

```sql
DECLARE
    CURSOR c_usuarios IS
        SELECT NOMBRE FROM USUARIOS ORDER BY ID_USUARIO;
    v_nombre USUARIOS.NOMBRE%TYPE;
BEGIN
    OPEN c_usuarios;
    LOOP
        FETCH c_usuarios INTO v_nombre;
        EXIT WHEN c_usuarios%NOTFOUND;
        IF c_usuarios%FOUND THEN
            DBMS_OUTPUT.PUT_LINE('  ' || v_nombre);
        END IF;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('Se han leido ' || c_usuarios%ROWCOUNT || ' usuarios en total.');
    CLOSE c_usuarios;
END;
/
```

#### Ejercicio 4 — Combinar los cuatro atributos

```sql
DECLARE
    CURSOR c_productos IS
        SELECT NOMBRE FROM PRODUCTOS ORDER BY PRECIO DESC;
    v_nombre PRODUCTOS.NOMBRE%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('%ISOPEN antes de OPEN: ' ||
        CASE WHEN c_productos%ISOPEN THEN 'TRUE' ELSE 'FALSE' END);

    OPEN c_productos;

    DBMS_OUTPUT.PUT_LINE('%ISOPEN tras OPEN   : ' ||
        CASE WHEN c_productos%ISOPEN THEN 'TRUE' ELSE 'FALSE' END);

    LOOP
        FETCH c_productos INTO v_nombre;
        EXIT WHEN c_productos%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
            'Fila ' || c_productos%ROWCOUNT ||
            ' | ' || RPAD(v_nombre, 22) ||
            ' | %FOUND=' || CASE WHEN c_productos%FOUND THEN 'TRUE' ELSE 'FALSE' END
        );
    END LOOP;

    DBMS_OUTPUT.PUT_LINE('%ROWCOUNT total : ' || c_productos%ROWCOUNT);
    DBMS_OUTPUT.PUT_LINE('%NOTFOUND final : ' ||
        CASE WHEN c_productos%NOTFOUND THEN 'TRUE' ELSE 'FALSE' END);

    CLOSE c_productos;

    DBMS_OUTPUT.PUT_LINE('%ISOPEN tras CLOSE  : ' ||
        CASE WHEN c_productos%ISOPEN THEN 'TRUE' ELSE 'FALSE' END);
END;
/
```

---

## BLOQUE 8 — Triggers

### Ejercicios principales

#### Ejercicio 1 — Registrar nuevos usuarios en un log

```sql
-- Tabla de log
CREATE TABLE LOG_USUARIOS (
    ID_LOG     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ID_USUARIO NUMBER,
    NOMBRE     VARCHAR2(100),
    FECHA_ALTA DATE,
    ACCION     VARCHAR2(50)
);

-- Trigger
CREATE OR REPLACE TRIGGER trg_log_usuario
    AFTER INSERT ON USUARIOS
    FOR EACH ROW
BEGIN
    INSERT INTO LOG_USUARIOS (ID_USUARIO, NOMBRE, FECHA_ALTA, ACCION)
    VALUES (:NEW.ID_USUARIO, :NEW.NOMBRE, SYSDATE, 'NUEVO USUARIO');
END trg_log_usuario;
/

-- Prueba
INSERT INTO USUARIOS (ID_USUARIO, NOMBRE, EMAIL, CIUDAD, EDAD, ACTIVO)
VALUES (11, 'Carmen Gil', 'carmen@mail.com', 'Murcia', 32, 'S');

SELECT ID_LOG, ID_USUARIO, NOMBRE, ACCION,
       TO_CHAR(FECHA_ALTA, 'DD/MM/YYYY HH24:MI') AS FECHA
FROM   LOG_USUARIOS;

ROLLBACK;
```

#### Ejercicio 2 — Impedir borrar usuarios con pedidos

```sql
CREATE OR REPLACE TRIGGER trg_proteger_usuario
    BEFORE DELETE ON USUARIOS
    FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM   PEDIDOS
    WHERE  ID_USUARIO = :OLD.ID_USUARIO;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20010,
            'No se puede borrar el usuario ' || :OLD.NOMBRE ||
            '. Tiene ' || v_count || ' pedido(s) asociado(s).');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Usuario ' || :OLD.NOMBRE || ' eliminado correctamente.');
    END IF;
END trg_proteger_usuario;
/

-- Prueba
BEGIN
    DELETE FROM USUARIOS WHERE ID_USUARIO = 1;  -- Debe fallar
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

BEGIN
    DELETE FROM USUARIOS WHERE ID_USUARIO = 8;  -- Debe funcionar
    ROLLBACK;
END;
/
```

#### Ejercicio 3 — Actualizar stock al insertar un pedido

```sql
CREATE OR REPLACE TRIGGER trg_actualizar_stock
    AFTER INSERT ON PEDIDOS
    FOR EACH ROW
DECLARE
    v_nombre PRODUCTOS.NOMBRE%TYPE;
    v_nuevo_stock PRODUCTOS.STOCK%TYPE;
BEGIN
    UPDATE PRODUCTOS
    SET    STOCK = STOCK - :NEW.CANTIDAD
    WHERE  ID_PRODUCTO = :NEW.ID_PRODUCTO
    RETURNING NOMBRE, STOCK INTO v_nombre, v_nuevo_stock;

    DBMS_OUTPUT.PUT_LINE(
        'Stock de ' || v_nombre || ' actualizado. Nuevo stock: ' ||
        v_nuevo_stock || ' unidades.'
    );
END trg_actualizar_stock;
/

-- Prueba
INSERT INTO PEDIDOS (ID_PEDIDO, ID_USUARIO, ID_PRODUCTO, CANTIDAD, ESTADO)
VALUES (101, 1, 6, 2, 'PENDIENTE');

SELECT NOMBRE, STOCK FROM PRODUCTOS WHERE ID_PRODUCTO = 6;

ROLLBACK;
```

#### Ejercicio 4 — Auditar cambios de estado en PEDIDOS

```sql
CREATE TABLE LOG_PEDIDOS (
    ID_LOG         NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ID_PEDIDO      NUMBER,
    ESTADO_ANTES   VARCHAR2(20),
    ESTADO_DESPUES VARCHAR2(20),
    FECHA_CAMBIO   DATE DEFAULT SYSDATE,
    USUARIO_BD     VARCHAR2(50) DEFAULT USER
);

CREATE OR REPLACE TRIGGER trg_auditoria_pedido
    AFTER UPDATE OF ESTADO ON PEDIDOS
    FOR EACH ROW
    WHEN (OLD.ESTADO <> NEW.ESTADO)
BEGIN
    INSERT INTO LOG_PEDIDOS (ID_PEDIDO, ESTADO_ANTES, ESTADO_DESPUES)
    VALUES (:OLD.ID_PEDIDO, :OLD.ESTADO, :NEW.ESTADO);
END trg_auditoria_pedido;
/

-- Prueba
UPDATE PEDIDOS SET ESTADO = 'ENVIADO' WHERE ID_PEDIDO = 5;

SELECT ID_LOG, ID_PEDIDO, ESTADO_ANTES, ESTADO_DESPUES,
       TO_CHAR(FECHA_CAMBIO, 'DD/MM/YYYY HH24:MI') AS FECHA,
       USUARIO_BD
FROM   LOG_PEDIDOS;

ROLLBACK;
```

#### Ejercicio 5 — Trigger de sentencia: registrar acceso a PRODUCTOS

```sql
CREATE TABLE LOG_ACCESOS (
    ID_LOG     NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    TABLA      VARCHAR2(50),
    OPERACION  VARCHAR2(10),
    FECHA      DATE DEFAULT SYSDATE,
    USUARIO_BD VARCHAR2(50) DEFAULT USER
);

CREATE OR REPLACE TRIGGER trg_acceso_productos
    AFTER INSERT OR UPDATE OR DELETE ON PRODUCTOS
DECLARE
    v_op VARCHAR2(10);
BEGIN
    IF    INSERTING THEN v_op := 'INSERT';
    ELSIF UPDATING  THEN v_op := 'UPDATE';
    ELSE                 v_op := 'DELETE';
    END IF;

    INSERT INTO LOG_ACCESOS (TABLA, OPERACION)
    VALUES ('PRODUCTOS', v_op);

    DBMS_OUTPUT.PUT_LINE('Acceso registrado: ' || v_op || ' en PRODUCTOS');
END trg_acceso_productos;
/

-- Prueba UPDATE
UPDATE PRODUCTOS SET PRECIO = PRECIO * 1.01 WHERE ROWNUM <= 5;

SELECT ID_LOG, TABLA, OPERACION,
       TO_CHAR(FECHA, 'DD/MM/YYYY HH24:MI') AS FECHA,
       USUARIO_BD
FROM   LOG_ACCESOS;

ROLLBACK;
```

#### Ejercicio 6 — BEFORE UPDATE: no permitir bajar precios

```sql
CREATE OR REPLACE TRIGGER trg_precio_minimo
    BEFORE UPDATE OF PRECIO ON PRODUCTOS
    FOR EACH ROW
BEGIN
    IF :NEW.PRECIO < :OLD.PRECIO THEN
        RAISE_APPLICATION_ERROR(-20020,
            'No se puede bajar el precio de ' || :OLD.NOMBRE || '. ' ||
            'Precio actual: ' || :OLD.PRECIO || ' EUR. ' ||
            'Precio propuesto: ' || :NEW.PRECIO || ' EUR.');
    ELSE
        DBMS_OUTPUT.PUT_LINE(
            'Precio de ' || :OLD.NOMBRE || ' actualizado: ' ||
            :OLD.PRECIO || ' -> ' || :NEW.PRECIO || ' EUR.'
        );
    END IF;
END trg_precio_minimo;
/

-- Prueba bajar precio (debe fallar)
BEGIN
    UPDATE PRODUCTOS SET PRECIO = 299.00 WHERE ID_PRODUCTO = 3;
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

-- Prueba subir precio (debe funcionar)
UPDATE PRODUCTOS SET PRECIO = 379.00 WHERE ID_PRODUCTO = 3;
ROLLBACK;
```

---

### Más ejercicios de triggers

#### Ejercicio 1 — Mensaje de bienvenida al insertar usuario

```sql
CREATE OR REPLACE TRIGGER trg_bienvenida_usuario
    AFTER INSERT ON USUARIOS
    FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE(
        'Bienvenido/a ' || :NEW.NOMBRE || '! Tu cuenta ha sido creada correctamente.'
    );
END trg_bienvenida_usuario;
/

-- Prueba
INSERT INTO USUARIOS (ID_USUARIO, NOMBRE, EMAIL, CIUDAD, EDAD, ACTIVO)
VALUES (11, 'Clara Vega', 'clara@mail.com', 'Murcia', 27, 'S');
ROLLBACK;
```

#### Ejercicio 2 — Mostrar precio anterior y nuevo al actualizar

```sql
CREATE OR REPLACE TRIGGER trg_cambio_precio
    AFTER UPDATE OF PRECIO ON PRODUCTOS
    FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE(
        'Producto: ' || :OLD.NOMBRE ||
        ' | Precio anterior: ' || :OLD.PRECIO || ' EUR' ||
        ' | Precio nuevo: '    || :NEW.PRECIO || ' EUR'
    );
END trg_cambio_precio;
/

-- Prueba
UPDATE PRODUCTOS SET PRECIO = 69.95 WHERE ID_PRODUCTO = 6;
ROLLBACK;
```

#### Ejercicio 3 — Impedir insertar productos con precio negativo

```sql
CREATE OR REPLACE TRIGGER trg_precio_positivo
    BEFORE INSERT ON PRODUCTOS
    FOR EACH ROW
BEGIN
    IF :NEW.PRECIO <= 0 THEN
        RAISE_APPLICATION_ERROR(-20001,
            'El precio no puede ser 0 ni negativo. Precio introducido: ' ||
            :NEW.PRECIO || ' EUR.');
    ELSE
        DBMS_OUTPUT.PUT_LINE(
            'Producto ' || :NEW.NOMBRE ||
            ' listo para insertar con precio ' || :NEW.PRECIO || ' EUR.'
        );
    END IF;
END trg_precio_positivo;
/

-- Prueba precio negativo (debe fallar)
BEGIN
    INSERT INTO PRODUCTOS (ID_PRODUCTO, NOMBRE, PRECIO, STOCK, CATEGORIA)
    VALUES (9, 'Test Negativo', -15, 10, 'Test');
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

-- Prueba precio correcto
INSERT INTO PRODUCTOS (ID_PRODUCTO, NOMBRE, PRECIO, STOCK, CATEGORIA)
VALUES (9, 'Altavoz BT', 49.99, 20, 'Audio');
ROLLBACK;
```

#### Ejercicio 4 — Contar cuántos pedidos tiene un usuario al insertar

```sql
CREATE OR REPLACE TRIGGER trg_contar_pedidos
    AFTER INSERT ON PEDIDOS
    FOR EACH ROW
DECLARE
    v_total NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_total
    FROM   PEDIDOS
    WHERE  ID_USUARIO = :NEW.ID_USUARIO;

    DBMS_OUTPUT.PUT_LINE(
        'El usuario ' || :NEW.ID_USUARIO ||
        ' ahora tiene ' || v_total || ' pedido(s) en total.'
    );
END trg_contar_pedidos;
/

-- Prueba
INSERT INTO PEDIDOS (ID_PEDIDO, ID_USUARIO, ID_PRODUCTO, CANTIDAD, ESTADO)
VALUES (101, 2, 8, 1, 'PENDIENTE');
ROLLBACK;
```

#### Ejercicio 5 — Registrar la fecha de modificación de un usuario

```sql
-- Primero añadir la columna
ALTER TABLE USUARIOS ADD FECHA_MODIFICACION DATE;

CREATE OR REPLACE TRIGGER trg_fecha_modificacion
    BEFORE UPDATE ON USUARIOS
    FOR EACH ROW
BEGIN
    :NEW.FECHA_MODIFICACION := SYSDATE;
    DBMS_OUTPUT.PUT_LINE(
        'Usuario ' || :OLD.NOMBRE ||
        ' modificado el ' || TO_CHAR(SYSDATE, 'DD/MM/YYYY HH24:MI:SS') || '.'
    );
END trg_fecha_modificacion;
/

-- Prueba
UPDATE USUARIOS SET CIUDAD = 'Bilbao' WHERE ID_USUARIO = 1;

SELECT NOMBRE, CIUDAD,
       TO_CHAR(FECHA_MODIFICACION, 'DD/MM/YYYY HH24:MI:SS') AS MODIFICADO
FROM   USUARIOS WHERE ID_USUARIO = 1;

ROLLBACK;
```

#### Ejercicio 6 — Avisar cuando el stock de un producto llega a 0

```sql
CREATE OR REPLACE TRIGGER trg_aviso_stock_cero
    AFTER UPDATE OF STOCK ON PRODUCTOS
    FOR EACH ROW
BEGIN
    IF :NEW.STOCK = 0 THEN
        DBMS_OUTPUT.PUT_LINE(
            'ALERTA: El producto ' || :NEW.NOMBRE || ' se ha quedado sin stock!'
        );
    ELSIF :NEW.STOCK <= 5 THEN
        DBMS_OUTPUT.PUT_LINE(
            'AVISO: Stock bajo en ' || :NEW.NOMBRE ||
            '. Quedan ' || :NEW.STOCK || ' unidades.'
        );
    END IF;
END trg_aviso_stock_cero;
/

-- Prueba stock = 0
UPDATE PRODUCTOS SET STOCK = 0 WHERE ID_PRODUCTO = 5;
ROLLBACK;

-- Prueba stock bajo
UPDATE PRODUCTOS SET STOCK = 4 WHERE ID_PRODUCTO = 5;
ROLLBACK;
```

#### Ejercicio 7 — Impedir cancelar un pedido ya entregado

```sql
CREATE OR REPLACE TRIGGER trg_proteger_entregado
    BEFORE UPDATE OF ESTADO ON PEDIDOS
    FOR EACH ROW
BEGIN
    IF :OLD.ESTADO = 'ENTREGADO' AND :NEW.ESTADO <> 'ENTREGADO' THEN
        RAISE_APPLICATION_ERROR(-20030,
            'El pedido #' || :OLD.ID_PEDIDO ||
            ' ya fue ENTREGADO y no puede cambiar su estado.');
    ELSE
        DBMS_OUTPUT.PUT_LINE(
            'Pedido #' || :OLD.ID_PEDIDO || ': estado cambiado de ' ||
            :OLD.ESTADO || ' a ' || :NEW.ESTADO || '.'
        );
    END IF;
END trg_proteger_entregado;
/

-- Prueba pedido #1 ENTREGADO -> CANCELADO (debe fallar)
BEGIN
    UPDATE PEDIDOS SET ESTADO = 'CANCELADO' WHERE ID_PEDIDO = 1;
EXCEPTION WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
/

-- Prueba pedido #5 PENDIENTE -> ENVIADO (debe funcionar)
UPDATE PEDIDOS SET ESTADO = 'ENVIADO' WHERE ID_PEDIDO = 5;
ROLLBACK;
```

#### Ejercicio 8 — Log de productos eliminados

```sql
CREATE TABLE LOG_BAJAS_PRODUCTOS (
    ID_LOG      NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ID_PRODUCTO NUMBER,
    NOMBRE      VARCHAR2(100),
    PRECIO      NUMBER(10,2),
    FECHA_BAJA  DATE DEFAULT SYSDATE
);

CREATE OR REPLACE TRIGGER trg_log_baja_producto
    BEFORE DELETE ON PRODUCTOS
    FOR EACH ROW
BEGIN
    INSERT INTO LOG_BAJAS_PRODUCTOS (ID_PRODUCTO, NOMBRE, PRECIO)
    VALUES (:OLD.ID_PRODUCTO, :OLD.NOMBRE, :OLD.PRECIO);

    DBMS_OUTPUT.PUT_LINE(
        'Producto ' || :OLD.NOMBRE || ' registrado en el log de bajas.'
    );
END trg_log_baja_producto;
/

-- Prueba
DELETE FROM PRODUCTOS WHERE ID_PRODUCTO = 7;

SELECT ID_LOG, ID_PRODUCTO, NOMBRE, PRECIO,
       TO_CHAR(FECHA_BAJA, 'DD/MM/YYYY HH24:MI') AS FECHA
FROM   LOG_BAJAS_PRODUCTOS;

ROLLBACK;
```

#### Ejercicio 9 — Trigger de sentencia en PEDIDOS

```sql
CREATE OR REPLACE TRIGGER trg_sentencia_pedidos
    AFTER INSERT OR UPDATE OR DELETE ON PEDIDOS
DECLARE
    v_op VARCHAR2(10);
BEGIN
    IF    INSERTING THEN v_op := 'INSERT';
    ELSIF UPDATING  THEN v_op := 'UPDATE';
    ELSE                 v_op := 'DELETE';
    END IF;

    DBMS_OUTPUT.PUT_LINE(
        'Operacion ' || v_op || ' ejecutada sobre la tabla PEDIDOS.'
    );
END trg_sentencia_pedidos;
/

-- Prueba: un solo UPDATE que afecta a varios pedidos
UPDATE PEDIDOS SET ESTADO = 'ENVIADO' WHERE ESTADO = 'PENDIENTE';
-- El mensaje debe aparecer UNA SOLA VEZ
ROLLBACK;
```

#### Ejercicio 10 — Normalizar el nombre de usuario a mayúsculas

```sql
CREATE OR REPLACE TRIGGER trg_normalizar_nombre
    BEFORE INSERT OR UPDATE ON USUARIOS
    FOR EACH ROW
BEGIN
    DBMS_OUTPUT.PUT_LINE(
        'Nombre normalizado: ' || :NEW.NOMBRE || ' -> ' || UPPER(:NEW.NOMBRE)
    );
    :NEW.NOMBRE := UPPER(:NEW.NOMBRE);
END trg_normalizar_nombre;
/

-- Prueba INSERT
INSERT INTO USUARIOS (ID_USUARIO, NOMBRE, EMAIL, CIUDAD, EDAD, ACTIVO)
VALUES (11, 'pedro sanchez', 'pedro@mail.com', 'Madrid', 40, 'S');

SELECT NOMBRE FROM USUARIOS WHERE ID_USUARIO = 11;
ROLLBACK;

-- Prueba UPDATE
UPDATE USUARIOS SET NOMBRE = 'luis garcia rodriguez' WHERE ID_USUARIO = 2;
SELECT NOMBRE FROM USUARIOS WHERE ID_USUARIO = 2;
ROLLBACK;
```

---

*Fin del documento — todos los ejercicios resueltos.*
