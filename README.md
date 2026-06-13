# Chatarra Polar

## Descripción

**Chatarra Polar** es un videojuego 2D de supervivencia y exploración desarrollado con **Godot 4**.

El protagonista es **Chispa**, un pingüino explorador que debe sobrevivir al frío extremo, recolectar materiales dispersos por el mapa, mejorar su base de operaciones y, finalmente, llegar físicamente hasta una antena de comunicación para repararla.

> Actualmente es un **prototipo jugable / demo en desarrollo**.

---

## Objetivo del juego

1. Explorar el mapa y sus distintas zonas.
2. Recolectar chatarra y piezas especiales.
3. Regresar a la base antes de congelarse.
4. Fabricar mejoras en la mesa de trabajo.
5. Sobrevivir al frío, las tormentas y los drones enemigos.
6. Llegar físicamente hasta la antena rota.
7. Repararla junto a ella para completar la demo.

---

## Ciclo principal

```
Explorar → Recolectar → Volver a la base → Mejorar → Avanzar hacia zonas más peligrosas
```

---

## Funcionalidades implementadas

- Movimiento en cuatro direcciones (WASD).
- Animaciones de Chispa: idle, caminata y deslizamiento en las cuatro direcciones.
- Deslizamiento del jugador.
- Recolección de chatarra y piezas especiales (baterías, cables, engranajes raros).
- Mochila con capacidad limitada y respawn programado de la chatarra después de una recolección exitosa. Si la mochila está llena, el objeto permanece disponible en el mapa.
- Sistema de calor y congelamiento: el frío baja con el tiempo y en zonas peligrosas.
- Recuperación de calor al estar en la base.
- Tormentas que aumentan el daño térmico.
- Zonas del mapa con distintas condiciones (zona segura, zona peligrosa, zona de chatarra).
- Drones enemigos con IA y tres variantes visuales (rojo, naranja, azul).
- Daño por contacto con drones y recompensas de chatarra al destruirlos.
- Base exterior con cuatro niveles visuales según el progreso.
- Interior de la base con cuatro niveles visuales y mesa de mejoras.
- Mesa de mejoras con progresión en cadena: mochila → caldera → botas térmicas.
- Equipamiento crafteable adicional: guantes magnéticos, aislante térmico, radar de piezas y taller de fabricación.
- Antena rota en el mapa, que solo puede repararse al estar físicamente junto a ella.
- Objetivos secundarios: explorador, recolector y superviviente.
- Guardado local automático del progreso.
- Interfaz de juego: HUD, barra de calor, minimapa, brújula de objetivo, radio de Tito Tuerca, menú de pausa.
- Intro narrativa y pantalla de demo completada.

---

## Tecnologías utilizadas

| Tecnología | Uso |
|---|---|
| **Godot Engine 4** | Motor de juego (GL Compatibility, Jolt Physics) |
| **GDScript** | Lenguaje principal del proyecto |
| **JSON** | Persistencia local del progreso |
| **Git / GitHub** | Control de versiones |
| **Visual Studio Code** | Editor de código |
| **Pixel art** | Arte de personajes, base, ítems y drones |
| **Claude Code** | Herramienta de apoyo al desarrollo |

**Sobre Claude Code:** fue utilizado como herramienta de apoyo para analizar la estructura del proyecto, detectar inconsistencias, proponer correcciones y mejorar la organización del código. Las decisiones de diseño, la revisión, la integración de sistemas y las pruebas finales fueron realizadas por el desarrollador.

---

## Elementos de Godot utilizados

- `CharacterBody2D` — jugador y lógica de movimiento.
- `AnimatedSprite2D` — animaciones del jugador y los drones.
- `Area2D` — detección de proximidad (antena, chatarra, piezas especiales, zonas).
- `StaticBody2D` — límites del mapa, paredes del interior y obstáculos.
- `CollisionShape2D` — formas de colisión de todos los cuerpos.
- `Camera2D` — cámara que sigue al jugador.
- `CanvasLayer` — capa de interfaz de usuario.
- `Control` — nodos de UI.
- Señales — comunicación entre nodos (entrada/salida de áreas, cuerpos).
- Escenas reutilizables — chatarra, piezas especiales, drones, obstáculos.
- Sistema de entrada — acciones definidas en `project.godot`.
- Guardado con archivos JSON mediante `FileAccess`.

---

## Cómo encaré el desarrollo

El proyecto fue desarrollado de forma **incremental**, comenzando por el núcleo jugable y expandiendo cada sistema de manera aislada antes de integrarlo.

**Primero** se implementó el movimiento del jugador y el ciclo básico de recolección de chatarra.

**Después** se agregaron, en orden aproximado:

- Sistema de temperatura y congelamiento.
- Drones enemigos con IA.
- Base exterior e interior con transición entre ambas.
- Mochila con límite de capacidad.
- Mesa de mejoras con progresión en cadena.
- Antena como objetivo físico en el mapa.
- Equipamiento crafteable adicional.
- Interfaz completa: HUD, minimapa, brújula, radio.
- Guardado y carga de progreso.
- Intro narrativa y pantalla final.

Cada sistema fue probado de forma individual antes de integrarlo con el resto del juego.

---

## Estructura del proyecto

```text
chatarra-polar/
├── project.godot
├── main_menu.tscn / main_menu.gd
├── base.gd
├── enemy_drone.gd
├── decor_sign.tscn / decor_sign.gd
├── README.md
├── .gitignore
├── Scenes/
│   ├── main.tscn / main.gd          ← controlador central del juego
│   ├── player.tscn / player.gd      ← jugador (CharacterBody2D)
│   ├── scrap.tscn / scrap.gd        ← ítem chatarra recolectable
│   ├── special_part.tscn            ← piezas especiales
│   ├── antenna.tscn / antenna.gd    ← antena de comunicación
│   ├── enemy_drone.tscn             ← dron enemigo
│   ├── base.tscn                    ← base exterior
│   ├── base_interior.gd             ← interior de la base
│   ├── base_upgrade_panel.gd        ← panel de mejoras
│   ├── upgrade_area.gd              ← área de interacción con la mesa
│   ├── zone_system.gd               ← sistema de zonas del mapa
│   ├── weather_fx.gd                ← efectos visuales de tormenta
│   ├── save_manager.gd              ← guardado/carga en JSON
│   ├── sound_manager.gd             ← audio procedural
│   ├── mini_map_hub.gd              ← minimapa
│   └── [otros sistemas de UI e ítems crafteables]
└── Sprite/
    ├── Chispa/
    ├── Base/
    ├── BaseInterior/
    ├── Antenna/
    ├── Drone/
    └── Items/
```

---

## Controles

| Tecla         | Acción                                                                             |
| ------------- | ---------------------------------------------------------------------------------- |
| W / A / S / D | Mover a Chispa                                                                     |
| Espacio       | Deslizamiento                                                                      |
| E             | Interactuar, utilizar la mesa o reparar la antena                                  |
| Escape        | Pausar o reanudar                                                                  |
| R             | Reiniciar después de congelarse o iniciar una nueva partida desde el menú de pausa |

---

## Cómo ejecutar el proyecto

1. Instalar **Godot 4** desde [godotengine.org](https://godotengine.org).
2. Clonar o descargar este repositorio.
3. Abrir Godot y seleccionar **Importar proyecto**.
4. Navegar hasta `project.godot` y abrirlo.
5. Presionar **F5** para ejecutar el juego.

---

## Guardado

El progreso se guarda automáticamente en archivos **JSON** dentro de la carpeta `user://` del sistema operativo.

Se guarda el siguiente estado:

- Chatarra en base y en mochila.
- Piezas especiales recolectadas.
- Mejoras desbloqueadas (mochila, caldera, botas térmicas).
- Estado de la antena y de la demo.
- Parámetros de mochila y caldera (capacidad y velocidades de calor).
- Misión principal completada.

---

## Principales desafíos técnicos

- Mantener la coherencia entre los frames de animación de Chispa en todas las direcciones.
- Administrar correctamente el límite de la mochila y el respawn de chatarra al llenarse.
- Coordinar el sistema de calor con las tormentas y las distintas zonas del mapa.
- Conectar el exterior y el interior de la base como una transición coherente dentro de la misma escena.
- Evitar que la mesa de mejoras procesara una compra en el mismo frame en que se abría.
- Asegurar que la antena solo pudiera repararse al estar físicamente junto a ella, sin atajos desde la mesa.
- Organizar las rutas y los recursos de sprites en subcarpetas sin romper las referencias de escena.
- Mantener el guardado consistente entre sesiones y sistemas independientes.

---

## Próximas mejoras

- Mayor variedad de enemigos con comportamientos distintos.
- Nuevos sectores y zonas del mapa.
- Sonido ambiental y música original.
- Efectos visuales adicionales (partículas, impactos).
- Sistema de iluminación dinámica.
- Balance de dificultad ajustado.
- Más animaciones para Chispa y los enemigos.
- Interfaz de usuario mejorada.
- Nuevas mejoras, ítems y misiones.

---

## Capturas

![Exploración](docs/exploracion.png)
![Interior de la base](docs/interior-base.png)
![Mesa de mejoras](docs/mesa-mejoras.png)
![Antena](docs/antena.png)

---

## Estado del proyecto

`Versión actual: prototipo jugable / demo en desarrollo.`

---

## Autor

**Ignacio Gabriel Godoy**

- Correo: [nachogodoy04@gmail.com](mailto:nachogodoy04@gmail.com)
- GitHub: *(próximamente)*
- LinkedIn: *(próximamente)*
- Demo descargable: *(próximamente)*
