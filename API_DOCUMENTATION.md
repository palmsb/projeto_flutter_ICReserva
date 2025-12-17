# Documentação da API Interna - ICReserva

Esta documentação descreve a estrutura da API interna do projeto ICReserva, detalhando as entidades, repositórios e fluxos de operações CRUD.

## Visão Geral

O projeto utiliza o **Supabase** como backend (BaaS). A comunicação com o banco de dados é abstraída através de **Repositórios**, que encapsulam a lógica de acesso a dados e regras de negócio simples (como validação de conflitos de horário).

## Entidades (Models)

As principais entidades do sistema são definidas no diretório `lib/models`. Elas utilizam `freezed` para imutabilidade e serialização JSON.

### 1. Reservation (Reserva)
Representa uma reserva de sala.
- **Campos**:
  - `id`: Identificador único (UUID).
  - `roomId`: ID da sala reservada.
  - `userId`: ID do usuário que fez a reserva.
  - `startDate`: Data e hora de início.
  - `endDate`: Data e hora de término.
  - `attendees`: Número de participantes.
  - `purpose`: Propósito da reserva.
  - `status`: Status da reserva (`pending`, `confirmed`, `cancelled`, `completed`).
  - `notes`: Observações adicionais.
  - `createdAt`, `updatedAt`: Timestamps de auditoria.

### 2. Room (Sala)
Representa uma sala disponível para reserva.
- **Campos**:
  - `id`: Identificador único (UUID).
  - `name`: Nome da sala.
  - `description`: Descrição detalhada.
  - `capacity`: Capacidade máxima de pessoas.
  - `location`: Localização da sala.
  - `photoUrl`: URL da foto da sala.
  - `amenities`: Lista de comodidades (ex: Projetor, Ar condicionado).
  - `isActive`: Indica se a sala está disponível para uso.
  - `createdAt`, `updatedAt`: Timestamps de auditoria.

### 3. User (Usuário)
Representa um usuário do sistema.
- **Campos**:
  - `id`: Identificador único (UUID).
  - `email`: Email do usuário.
  - `name`: Nome completo.
  - `phone`: Telefone de contato.
  - `photoUrl`: URL da foto de perfil.
  - `department`: Departamento do usuário.
  - `createdAt`, `updatedAt`: Timestamps de auditoria.

---

## Repositórios e Fluxos CRUD

Os repositórios estão localizados em `lib/repositories` e são responsáveis por interagir com o Supabase.

### ReservationRepository

Gerencia as operações relacionadas às reservas.

#### **Create (Criar Reserva)**
- **Função**: `create(Reservation reservation)`
- **Fluxo**:
  1. Recebe um objeto `Reservation`.
  2. Converte para JSON (`toJson()`).
  3. Remove campos gerados pelo banco (`id`, `created_at`, `updated_at`).
  4. Insere no banco de dados (`reservations`).
  5. Retorna o objeto `Reservation` criado com o ID gerado.
- **Erro**: Lança `Exception` em caso de falha.

#### **Read (Ler Reservas)**
- **GetById**: `getById(String id)` - Busca uma reserva específica.
- **GetAll**: `getAll()` - Lista todas as reservas ordenadas por data de início (decrescente).
- **GetByRoomId**: `getByRoomId(String roomId)` - Lista reservas de uma sala específica.
- **GetFutureReservationsByRoomId**: `getFutureReservationsByRoomId(String roomId)` - Lista apenas reservas futuras de uma sala.
- **GetByUserId**: `getByUserId(String userId)` - Lista reservas de um usuário.

#### **Update (Atualizar Reserva)**
- **Função**: `update(Reservation reservation)`
- **Fluxo**:
  1. Recebe o objeto `Reservation` com os novos dados.
  2. Atualiza o campo `updated_at` para o timestamp atual.
  3. Remove campos imutáveis (`id`, `created_at`).
  4. Executa o update no banco onde `id` corresponde.
  5. Retorna a reserva atualizada.

#### **Delete / Cancel (Remover/Cancelar)**
- **Delete**: `delete(String id)` - Remove fisicamente o registro do banco.
- **Cancel**: `cancel(String id)` - **Soft Delete lógico**.
  - Atualiza o status para `cancelled`.
  - Atualiza `updated_at`.
  - Mantém o histórico da reserva.

#### **Validação de Conflitos**
- **Função**: `hasTimeConflict(...)`
- **Fluxo**:
  1. Recebe `roomId`, `startDate`, `endDate` e opcionalmente `excludeReservationId` (para updates).
  2. Busca todas as reservas ativas (não canceladas) daquela sala.
  3. Itera sobre as reservas verificando sobreposição de horários:
     - `(StartA < EndB) && (EndA > StartB)`
  4. Retorna `true` se houver conflito, `false` caso contrário.

---

### RoomRepository

Gerencia as operações relacionadas às salas.

#### **Create (Criar Sala)**
- **Função**: `create(Room room)`
- **Fluxo**:
  1. Converte objeto para JSON.
  2. Remove campos de sistema (`id`, `created_at`, `updated_at`).
  3. Insere na tabela `rooms`.
  4. Retorna a sala criada.

#### **Read (Ler Salas)**
- **GetById**: `getById(String id)` - Busca sala por ID.
- **GetAll**: `getAll({bool onlyActive = true})` - Lista salas. Por padrão, traz apenas as ativas (`is_active = true`).

#### **Update (Atualizar Sala)**
- **Função**: `update(Room room)`
- **Fluxo**:
  1. Atualiza `updated_at`.
  2. Remove campos imutáveis.
  3. Atualiza registro no banco.

#### **Delete (Remover Sala)**
- **Delete (Soft)**: `delete(String id)`
  - Define `is_active = false`.
  - A sala permanece no banco para manter integridade referencial de reservas passadas.
- **DeletePermanently**: `deletePermanently(String id)`
  - Remove fisicamente o registro. Deve ser usado com cautela.

---

## Tratamento de Erros

Todos os métodos dos repositórios envolvem as chamadas ao Supabase em blocos `try-catch`.
- Em caso de erro, uma `Exception` genérica é lançada com uma mensagem descritiva (ex: "Erro ao criar reserva: ...").
- A camada de UI/Controller deve tratar essas exceções para feedback ao usuário.
