
-- Hacer que en la tabla detalle_pedido la columna id_producto concorde con todos los 12 productos producidos por la empresa 
SET SQL_SAFE_UPDATES = 0;
UPDATE detalle_pedido
SET id_producto = FLOOR(1 + (RAND() * 12));
-- Actualizar la tabla producto
ALTER TABLE produccion ADD COLUMN responsable_nuevo VARCHAR(50);
-- Eliminar la columna original responsable
ALTER TABLE produccion drop column responsable; 
UPDATE produccion
SET responsable_nuevo = CASE FLOOR(1 + (RAND() * 4))
  WHEN 1 THEN 'Judith Sabater Mendizábal'
  WHEN 2 THEN 'Cosme Guardiola Herrero'
  WHEN 3 THEN 'Martín Pedraza Torralba'
  WHEN 4 THEN 'Paulina Valencia Cabrero'
END;

SELECT responsable_nuevo, COUNT(*) AS cantidad
FROM produccion
GROUP BY responsable_nuevo;

ALTER TABLE produccion CHANGE COLUMN responsable_nuevo responsable VARCHAR(50);


-- Eliminar de la trabla proveedores las más de 1000 filas para tener solo 50 proveedores
DELETE p
FROM proveedores p
JOIN (
  SELECT id_proveedor
  FROM proveedores
  ORDER BY id_proveedor
  LIMIT 1000 OFFSET 50
) AS eliminar
ON p.id_proveedor = eliminar.id_proveedor;



-- Ahora comienza el script para crear las VIEWS, STORE PROCEDURES, TRIGGERS alter

-- Vista de PEDIDOS y LOTES para trazabilidad
USE vitivinicola;
CREATE VIEW pedidos_lote AS
SELECT 
    p.fecha_pedido,
    d.id_pedido,
    d.cantidad,
    d.precio_unitario,
    (d.cantidad * d.precio_unitario) AS costo_tot,
    CONCAT('ABC-', year(p.fecha_pedido), '-', d.id_pedido) AS lote
FROM pedidos p
INNER JOIN detalle_pedido d 
    ON p.id_pedido = d.id_pedido;
    
-- STORE PROCEDURE para observar solo los pedidos filtrados por mes y año.

DELIMITER //

CREATE PROCEDURE pedidos_ano_mes (
    IN valor_ano INT,
    IN mes INT
)
BEGIN
    SELECT *
    FROM pedidos_lote
    WHERE YEAR(fecha_pedido) = valor_ano
      AND MONTH(fecha_pedido) = mes
    ORDER BY fecha_pedido DESC;
END //

DELIMITER ;

CALL pedidos_ano_mes (2025,8);

-- Vista para ver los lotes no aceptados por el área de calidad, así que utilizamos las tablas c_calidad y produccion

CREATE VIEW lotes_estado AS
SELECT 
    pro.fecha_producida,
    cal.id_lote,
    pro.cantidad_producida,
    cal.resultado,
    IF(cal.resultado = 'Rechazado', 'En evaluación', 'Correcto') AS estado
FROM c_calidad cal
INNER JOIN produccion pro 
    ON cal.id_lote = pro.id_lote;
    
-- STORE PROCEDURE para llamar a los lotes en evaluación segun año y mes

DELIMITER //

CREATE PROCEDURE lotes_ano_mes (
    IN valor_ano INT,
    IN mes INT
)
BEGIN
    SELECT *
    FROM lotes_estado
    WHERE YEAR(fecha_producida) = valor_ano
      AND MONTH(fecha_producida) = mes
    ORDER BY fecha_producida DESC;
END //

DELIMITER ;

CALL lotes_ano_mes (2025,8);


-- Un ejemplo de TRIGGERS sería cuando se realiza un nuevo lote en producción, se crea automaticamente un id_control en c_calida
DELIMITER //

CREATE TRIGGER crear_control_calidad
AFTER INSERT ON produccion
FOR EACH ROW
BEGIN
    INSERT INTO c_calidad (id_lote)
    VALUES (NEW.id_lote);
END //

DELIMITER ;

-- Prueba de TRIGGER
SET SQL_SAFE_UPDATES = 0;
INSERT INTO produccion (id_lote, id_producto, cantidad_producida)
VALUES (1001, 5, 5050);
