# 📚 App Reserva de Salas

Aplicativo desenvolvido em Flutter para gerenciamento de salas de um instituto acadêmico.  
Permite **criar salas**, **listar**, **editar**, **excluir**, além de **criar e gerenciar reservas** vinculadas a essas salas.  
O projeto usa **Riverpod** e **persistência na nuvem com Supabase**.


## 🚀 Funcionalidades

### 🏢 CRUD de Salas
- Cadastrar nova sala  
- Editar dados da sala  
- Excluir sala  
- Listar todas as salas  
- Exibir detalhes completos da sala  

### 📅 CRUD de Reservas
- Criar reserva para uma sala  
- Editar reserva existente  
- Excluir reserva  
- Listar reservas futuras da sala  

### 📷 Recurso Extra: QR Code
- Gerar QR Code de cada sala  
- Ler QR Code usando a câmera  
- Ao escanear → abrir automaticamente a tela de detalhes da sala

### 🗺️ Mapa de Salas
- Visualização básica  
- Salas clicáveis  

## 📱 Telas do App

- Home – Lista de Salas  
- Criar Sala  
- Editar Sala  
- Detalhes da Sala  
- Criar Reserva  
- Editar Reserva  
- Scanner de QR Code  
- Preview de QR Code da Sala  
- Perfil  do Usuário

## 🛠️ Como Rodar o Projeto

### 1. Instale as dependências:
```sh
flutter pub get
flutter run
flutter analyze