# Informe de Auditoría de Contrato Inteligente

**Proyecto:** Lending Protocol  
**Fecha:** 20/05/2025  
**Auditor:** Copilot AI  
**Alcance:**  
- contracts/Lending.sol  
- contracts/OracleMock.sol  
- test/Lending.t.sol

---

## 1. Resumen Ejecutivo

Esta auditoría cubre un protocolo de préstamos simple implementado en Solidity (`Lending.sol`), con un oráculo de precios actualizable para pruebas (`OracleMock.sol`) y pruebas automatizadas (`Lending.t.sol`).  
El protocolo permite a los usuarios depositar ETH como colateral y pedir prestado USDC, incluyendo mecánicas de liquidación basadas en una ratio de colateralización mínima.

---

## 2. Descripción de la Arquitectura

### **LendingProtocol.sol**
- **Colateral:** ETH
- **Deuda:** USDC (ERC20)
- **Oráculo:** Contrato externo que provee el precio de ETH en USD (8 decimales)
- **Ratio de Colateralización:** Mínimo 150%
- **Recompensa de Liquidación:** 10% del colateral para el liquidador

### **OracleMock.sol**
- Contrato simple para establecer y obtener el precio de ETH/USD durante las pruebas.

### **Pruebas**
- Se utiliza un mock de USDC y un oráculo de precios mockeado.
- Las pruebas cubren depósito/prestamo, liquidaciones directas y pruebas fuzzing con parámetros aleatorios.

---

## 3. Hallazgos

### **3.1. Críticos/Alta Severidad**

- **No se encontraron vulnerabilidades de severidad crítica o alta.**

---

### **3.2. Severidad Media**

- **Manejo del Colateral Tras Liquidación**  
  El contrato paga al liquidador una recompensa del 10% del colateral, pero el 90% restante permanece en el contrato. No hay un mecanismo para que el owner del protocolo u otra parte reclame ese colateral restante. Esto puede ser deseado o no, según el diseño del protocolo.

- **No hay Función de Repago de Préstamos**  
  Los prestatarios no pueden devolver su deuda para recuperar su colateral. El protocolo es “unidireccional”: solo se permite depositar, pedir prestado o ser liquidado.  
  _Recomendación:_ Agregar una función que permita a los usuarios repagar su deuda y retirar su colateral.

---

### **3.3. Baja Severidad y Notas**

- **Confianza en el Oráculo**  
  El protocolo confía totalmente en el oráculo. En producción, debe usarse un oráculo descentralizado y resistente a manipulaciones (ejemplo: Chainlink).

- **Manejo de Decimales**  
  El protocolo maneja correctamente los decimales de ETH (18), el precio en USD (8) y USDC (6), y las pruebas lo verifican.

- **Variable No Usada**  
  Hay una variable local no utilizada en `Lending.sol` (`seized = loan.collateralAmount`). Puede eliminarse para mayor limpieza.

- **Reentrancia**  
  No hay llamadas externas tras el cambio de estado (la transferencia de ETH ocurre después de actualizar el estado), por lo que no es vulnerable a reentrancia.

- **Cobertura Fuzzing**  
  Las pruebas fuzz ahora restringen correctamente los valores de entrada para solo probar préstamos viables, evitando falsos negativos.

- **Oráculo Actualizable**  
  En pruebas, cualquiera puede actualizar el precio. En producción, restringe `setPrice` a cuentas autorizadas.

---

## 4. Resultados de Pruebas

- Todas las pruebas pasan tras los arreglos en las asunciones de entrada de `testLiquidateFuzz`.
- La cobertura incluye:
  - Depósito y préstamo estándar
  - Liquidaciones en casos límite
  - Pruebas fuzzing con muchos parámetros
- Ninguna prueba deja colateral ni USDC bloqueado en estados inconsistentes.

---

## 5. Recomendaciones

- **Agregar Función de Repago:**  
  Permitir que los usuarios repaguen su deuda para recuperar su colateral.

- **Mejorar la Gestión del Colateral Tras Liquidación:**  
  Decidir si el colateral restante debe poder ser reclamado, por quién, o si debe quemarse.

- **Oráculo de Producción:**  
  Sustituir `OracleMock` por un oráculo descentralizado y seguro.

- **Eliminar Variables Innecesarias:**  
  Limpia variables no usadas para evitar advertencias y mejorar la claridad.

---

## 6. Conclusión

El protocolo es simple y seguro bajo el diseño actual y la cobertura de pruebas existente. Se sugieren mejoras para robustez y completitud funcional de cara a producción.

---

## 7. Archivos Auditados

- `contracts/Lending.sol`
- `contracts/OracleMock.sol`
- `test/Lending.t.sol`

---

_Auditoría realizada automáticamente por Copilot AI. Para una revisión de seguridad completa, se recomienda también una inspección manual y análisis estático avanzado._