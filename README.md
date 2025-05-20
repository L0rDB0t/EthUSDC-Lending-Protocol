# EthUSDC Lending Protocol

## Descripción

**EthUSDC Lending Protocol** es una plataforma DeFi minimalista y transparente que permite a cualquier usuario depositar ETH como colateral y recibir USDC instantáneamente como préstamo. El sistema está diseñado con seguridad, claridad y pruebas rigurosas en mente, asegurando la máxima confianza para desarrolladores y usuarios.

---

## Características Destacadas

- **Seguridad ante todo:**  
  - La lógica de colateralización y liquidación ha sido auditada y probada exhaustivamente.
  - El contrato actualiza el estado antes de cualquier transferencia de ETH, previniendo ataques de reentrancia.
  - Los cálculos de decimales entre ETH, USDC y el oráculo son estrictamente consistentes, previniendo errores de precisión o overflow.

- **Transparencia y Simplicidad:**  
  - El código es corto, fácil de leer y está completamente documentado.
  - El oráculo está encapsulado en un contrato separado, facilitando auditorías y upgrades.

- **Liquidaciones Justas:**  
  - Si la ratio de colateralización de un préstamo baja de 150%, cualquier usuario puede liquidar ese préstamo y recibir una recompensa del 10% del colateral.
  - El proceso de liquidación es atomizado y resistente a errores.

- **Pruebas Exhaustivas:**  
  - El protocolo incluye pruebas unitarias y fuzzing, cubriendo tanto casos regulares como extremos.
  - Todas las funciones críticas están cubiertas por tests automatizados.

- **Auditoría Pública:**  
  - El proyecto incluye un [informe de auditoría detallado](audits/Report.md), donde se documentan los hallazgos, recomendaciones y la robustez del protocolo.

---

## Resultados de Auditoría y Seguridad

- **Sin vulnerabilidades críticas:**  
  La revisión detectó que la lógica de préstamos y liquidaciones es segura bajo el diseño actual.
- **Protección contra reentrancia:**  
  Todas las transferencias de ETH suceden después de la actualización del estado.
- **Pruebas pasadas al 100%:**  
  Los tests unitarios y fuzzing no dejan estados inconsistentes ni fondos bloqueados.
- **Cobertura de pruebas:**  
  Incluye depósito, préstamo, liquidación directa y fuzzing de parámetros aleatorios.

Consulta el informe completo en [`audits/Report.md`](audits/Report.md) para detalles técnicos, supuestos y recomendaciones de mejora.

---

## Instalación y Uso

1. **Clona el repositorio:**
   ```bash
   git clone <repo-url>
   cd lending-protocol
   ```

2. **Instala dependencias (Forge, OpenZeppelin).**

3. **Compila los contratos:**
   ```bash
   forge build
   ```

4. **Ejecuta las pruebas:**
   ```bash
   forge test
   ```

---

## Estructura del Proyecto

- `contracts/Lending.sol` — Contrato principal del protocolo de préstamos.
- `contracts/OracleMock.sol` — Oráculo mockeado de precios para pruebas.
- `test/Lending.t.sol` — Pruebas unitarias y fuzzing automatizado.
- `audits/Report.md` — Informe de auditoría y seguridad.
- `README.md` — Este archivo.

---

## Licencia

MIT

---

**EthUSDC Lending Protocol** — Sencillo, seguro, auditable.  
¡Participa, revisa o hackea el protocolo! Pull requests y sugerencias son bienvenidos.
