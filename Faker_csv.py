import pandas as pd
import random
from faker import Faker

fake = Faker('es_ES')  # Español para nombres y ciudades
n = 1000

# -------------------------------
# 1. Productos
# -------------------------------
productos = []
for i in range(1, n+1):
    productos.append([
        i,
        fake.word().capitalize(),
        random.choice(["Vino Tinto", "Vino Blanco", "Espumoso", "Rosado"]),
        random.randint(2010, 2024),
        round(random.uniform(10, 100), 2),
        random.randint(0, 5000)
    ])
df_productos = pd.DataFrame(productos, columns=["id_producto", "nombre", "tipo_producto", "ano_produccion", "precio_unitario", "stock_actual"])
df_productos.to_csv("productos.csv", index=False, encoding='latin1')

# -------------------------------
# 2. Clientes
# -------------------------------
clientes = []
for i in range(1, n+1):
    clientes.append([
        i,
        fake.name(),
        fake.email(),
        fake.random_number(digits=9),
        fake.city(),
        fake.country()
    ])
df_clientes = pd.DataFrame(clientes, columns=["id_cliente", "nombre_cliente", "correo", "telefono", "ciudad", "pais"])
df_clientes.to_csv("clientes.csv", index=False, encoding='latin1')

# -------------------------------
# 3. Pedidos
# -------------------------------
pedidos = []
for i in range(1, n+1):
    pedidos.append([
        i,
        fake.date_time_this_decade(),
        random.randint(1, n),  # FK a clientes
        round(random.uniform(50, 5000), 2)
    ])
df_pedidos = pd.DataFrame(pedidos, columns=["id_pedido", "fecha_pedido", "id_cliente", "total_pedido"])
df_pedidos.to_csv("pedidos.csv", index=False, encoding='latin1')

# -------------------------------
# 4. Detalle Pedido
# -------------------------------
detalle = []
for i in range(1, n+1):
    detalle.append([
        random.randint(1, n),  # FK a pedidos
        random.randint(1, n),  # FK a productos
        random.randint(1, 20),
        round(random.uniform(10, 100), 2)
    ])
df_detalle = pd.DataFrame(detalle, columns=["id_pedido", "id_producto", "cantidad", "precio_unitario"])
df_detalle.to_csv("detalle_pedido.csv", index=False, encoding='latin1')

# -------------------------------
# 5. Proveedores
# -------------------------------
proveedores = []
for i in range(1, n+1):
    proveedores.append([
        i,
        fake.company(),
        random.choice(["Botellas", "Corchos", "Barriles", "Etiquetas", "Uvas"]),
        fake.random_number(digits=9)
    ])
df_proveedores = pd.DataFrame(proveedores, columns=["id_proveedor", "nombre_proveedor", "producto_suministrado", "telefono"])
df_proveedores.to_csv("proveedores.csv", index=False, encoding='latin1')

# -------------------------------
# 6. Producción
# -------------------------------
produccion = []
for i in range(1, n+1):
    produccion.append([
        i,
        random.randint(1, n),  # FK a productos
        fake.date_this_decade(),
        random.randint(100, 5000),
        fake.name()
    ])
df_produccion = pd.DataFrame(produccion, columns=["id_lote", "id_producto", "fecha_producida", "cantidad_producida", "responsable"])
df_produccion.to_csv("produccion.csv", index=False, encoding='latin1')

# -------------------------------
# 7. Control de Calidad
# -------------------------------
c_calidad = []
for i in range(1, n+1):
    c_calidad.append([
        i,
        random.randint(1, n),  # FK a produccion
        round(random.uniform(0.95, 1.15), 3),
        round(random.uniform(3.0, 4.0), 2),
        round(random.uniform(8.0, 15.0), 2),
        random.choice(["Aprobado", "Rechazado"])
    ])
df_c_calidad = pd.DataFrame(c_calidad, columns=["id_control", "id_lote", "densidad", "ph", "grado_alcohol", "resultado"])
df_c_calidad.to_csv("c_calidad.csv", index=False, encoding='latin1')

print("✅ Archivos CSV generados con éxito")
