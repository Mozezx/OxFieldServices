# OX Field Services — Plano de Frontend
### Fases 11, 12 e 13 · Design System + Direção Visual

---

## Sumário

- [Design System](#design-system)
- [Fase 11 — Flutter App Cliente](#fase-11--flutter-app-cliente)
- [Fase 12 — Flutter App Trabalhador](#fase-12--flutter-app-trabalhador)
- [Fase 13 — React Admin Panel](#fase-13--react-admin-panel)
- [Checklist de Consistência Visual](#checklist-de-consistência-visual)
- [Internacionalização (i18n)](#internacionalização-i18n)

---

## Design System

> Padrão visual único compartilhado entre os dois apps Flutter e o painel React. Qualquer tela criada em qualquer plataforma deve seguir rigorosamente este guia.

---

### Paleta de Cores

| Token           | Hex / RGB              | Uso                                                            |
|-----------------|------------------------|----------------------------------------------------------------|
| `--color-primary`  | `#092F3D`           | Backgrounds, navbars, headers, sidebars, superfícies escuras   |
| `--color-secondary`| `#FFFFFF`           | Texto sobre fundo escuro, cards em modo claro, ícones          |
| `--color-accent`   | `#03FC30` (rgb 3,252,48) | CTAs principais, badges de status ativo, progresso, links |
| `--color-surface`  | `#0D3F52`           | Cards, modais, inputs sobre fundo primary (nível acima)        |
| `--color-surface-2`| `#0A4A62`           | Hover states, chips selecionados, painéis internos             |
| `--color-error`    | `#FF4C4C`           | Erros, rejeitado, alerta crítico                               |
| `--color-warning`  | `#FFA500`           | Pendente, em análise, atenção                                  |
| `--color-success`  | `#03FC30`           | Validado, pago, concluído (mesmo que accent)                   |
| `--color-text-primary`  | `#FFFFFF`      | Texto principal sobre fundos escuros                           |
| `--color-text-secondary`| `#A8C4CE`      | Texto secundário, labels, placeholders                         |
| `--color-text-disabled` | `#4A7A8A`      | Texto desabilitado                                             |
| `--color-divider`  | `#1A5570`           | Separadores, bordas sutis                                      |

```
Regra de ouro:
  - Fundo geral    → #092F3D
  - Cards / camada → #0D3F52
  - Ação principal → #03FC30  (texto interno: #092F3D)
  - Ação secundária→ borda branca, fundo transparente
```

---

### Degradês

Os degradês são **sutis** — não substituem cores sólidas, apenas adicionam profundidade. Nunca usar degradês saturados ou com muito contraste.

#### Degradês Permitidos

| Nome                 | Definição                                                                   | Uso                                               |
|----------------------|-----------------------------------------------------------------------------|---------------------------------------------------|
| `gradient-hero`      | `#092F3D → #0D3F52` (vertical, 180°)                                       | Header de telas principais, splash, onboarding    |
| `gradient-card`      | `#0D3F52 → #092F3D` (vertical, 180°, sutil)                                | Cards de destaque, project card ativo             |
| `gradient-accent`    | `#03FC30 → #00C828` (vertical, 180°)                                       | Botão primário (substitui cor sólida no btn CTA)  |
| `gradient-surface`   | `#0A4A62 → #0D3F52` (180°)                                                 | Modal, bottom sheet, painéis de detalhe           |
| `gradient-overlay`   | `transparent → rgba(9,47,61,0.95)` (vertical)                              | Overlay sobre imagens/fotos de evidência          |
| `gradient-sidebar`   | `#092F3D → #071F29` (vertical)                                             | Sidebar do admin (reforça hierarquia visual)       |

#### Implementação Flutter

```dart
// lib/core/theme/app_gradients.dart

class AppGradients {
  static const hero = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF092F3D), Color(0xFF0D3F52)],
  );

  static const card = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0D3F52), Color(0xFF092F3D)],
  );

  static const accent = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF03FC30), Color(0xFF00C828)],
  );

  static const surface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A4A62), Color(0xFF0D3F52)],
  );

  static const overlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xF2092F3D)],
  );
}

// Uso em widget:
Container(
  decoration: BoxDecoration(
    gradient: AppGradients.hero,
    borderRadius: BorderRadius.circular(16),
  ),
)

// Botão com degradê:
Ink(
  decoration: BoxDecoration(
    gradient: AppGradients.accent,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [BoxShadow(color: Color(0x4003FC30), blurRadius: 16, offset: Offset(0, 4))],
  ),
)
```

#### Implementação React (Tailwind + CSS)

```css
/* globals.css */
:root {
  --gradient-hero:    linear-gradient(180deg, #092F3D 0%, #0D3F52 100%);
  --gradient-card:    linear-gradient(180deg, #0D3F52 0%, #092F3D 100%);
  --gradient-accent:  linear-gradient(180deg, #03FC30 0%, #00C828 100%);
  --gradient-surface: linear-gradient(135deg, #0A4A62 0%, #0D3F52 100%);
  --gradient-overlay: linear-gradient(180deg, transparent 0%, rgba(9,47,61,0.95) 100%);
  --gradient-sidebar: linear-gradient(180deg, #092F3D 0%, #071F29 100%);
}
```

```js
// tailwind.config.ts — adicionar em backgroundImage
backgroundImage: {
  'gradient-hero':    'linear-gradient(180deg, #092F3D 0%, #0D3F52 100%)',
  'gradient-card':    'linear-gradient(180deg, #0D3F52 0%, #092F3D 100%)',
  'gradient-accent':  'linear-gradient(180deg, #03FC30 0%, #00C828 100%)',
  'gradient-surface': 'linear-gradient(135deg, #0A4A62 0%, #0D3F52 100%)',
  'gradient-overlay': 'linear-gradient(180deg, transparent 0%, rgba(9,47,61,0.95) 100%)',
  'gradient-sidebar': 'linear-gradient(180deg, #092F3D 0%, #071F29 100%)',
},

// Uso: className="bg-gradient-hero"
//      className="bg-gradient-accent"
```

#### Regras de Uso de Degradês

```
✅ Usar  → Splash screen (gradient-hero a tela cheia)
✅ Usar  → Onboarding (fundo com gradient-hero)
✅ Usar  → Header/AppBar com gradient-hero muito sutil
✅ Usar  → Botão CTA principal (gradient-accent no lugar de cor sólida)
✅ Usar  → Overlay sobre foto de evidência (gradient-overlay)
✅ Usar  → Card de projeto ativo em destaque (gradient-card)
✅ Usar  → Sidebar do admin (gradient-sidebar)

❌ Evitar → Degradês horizontais com cores muito diferentes
❌ Evitar → Mais de um degradê visível na mesma tela simultaneamente
❌ Evitar → Degradês sobre cards que já têm borda ou sombra pronunciada
❌ Evitar → Degradê no texto (legibilidade comprometida)
```

---

### Tipografia

#### Flutter (ambos os apps)

```dart
// Fonte: Inter (Google Fonts)
// flutter pub add google_fonts

TextTheme oxTextTheme = GoogleFonts.interTextTheme().copyWith(
  displayLarge:  GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
  displayMedium: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
  titleLarge:    GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
  titleMedium:   GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
  bodyLarge:     GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
  bodyMedium:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFFA8C4CE)),
  labelLarge:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF092F3D)),
  labelSmall:    GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFFA8C4CE)),
);
```

#### React Admin (Next.js)

```css
/* Fonte: Inter via Google Fonts ou next/font */
font-family: 'Inter', system-ui, -apple-system, sans-serif;

--text-xs:   0.75rem;   /* 12px — labels, badges */
--text-sm:   0.875rem;  /* 14px — body secundário */
--text-base: 1rem;      /* 16px — body principal */
--text-lg:   1.125rem;  /* 18px — subtítulos */
--text-xl:   1.25rem;   /* 20px — títulos de seção */
--text-2xl:  1.5rem;    /* 24px — títulos de página */
--text-3xl:  2rem;      /* 32px — display */

--font-normal:   400;
--font-medium:   500;
--font-semibold: 600;
--font-bold:     700;
```

---

### Espaçamento

```
Escala base: múltiplos de 4px

4px  → espaço mínimo (padding interno de chips)
8px  → espaço XS (gap entre ícone e label)
12px → espaço SM (padding de tags)
16px → espaço MD (padding padrão de card)
20px → espaço LG (gap entre seções)
24px → espaço XL (padding de telas)
32px → espaço 2XL (margem de títulos)
40px → espaço 3XL (espaçamento de blocos grandes)
```

---

### Componentes Base

#### Botão Primário

```
Background: #03FC30
Texto:      #092F3D  (bold, 14px)
Border-radius: 12px
Padding:    16px 24px
Sombra:     0 4px 16px rgba(3, 252, 48, 0.25)

Estado Hover/Press: brightness 90% + sombra aumenta
Estado Disabled: opacity 0.3
```

#### Botão Secundário

```
Background: transparente
Borda:      1.5px solid #FFFFFF
Texto:      #FFFFFF (semibold)
Border-radius: 12px
Padding:    16px 24px

Estado Hover: background rgba(255,255,255,0.08)
```

#### Card

```
Background:    #0D3F52
Border-radius: 16px
Padding:       20px
Sombra:        0 2px 12px rgba(0,0,0,0.3)
Borda sutil:   1px solid rgba(255,255,255,0.06)
```

#### Input Field

```
Background:    #0D3F52
Borda normal:  1px solid #1A5570
Borda focus:   1px solid #03FC30 + glow rgba(3,252,48,0.2)
Borda erro:    1px solid #FF4C4C
Border-radius: 12px
Padding:       14px 16px
Texto:         #FFFFFF
Placeholder:   #4A7A8A
Label:         #A8C4CE, 12px, medium
```

#### Badge de Status

| Status            | Background              | Texto      |
|-------------------|-------------------------|------------|
| Ativo / Validado  | rgba(3,252,48,0.15)     | `#03FC30`  |
| Pendente          | rgba(255,165,0,0.15)    | `#FFA500`  |
| Rejeitado / Erro  | rgba(255,76,76,0.15)    | `#FF4C4C`  |
| Neutro / Rascunho | rgba(255,255,255,0.08)  | `#A8C4CE`  |
| Em Execução       | rgba(3,252,48,0.08)     | `#A8C4CE`  |

---

### Logo — Regras de Uso

**Arquivo:** `assets/logo.webp` (copiar para cada projeto)

| Contexto                      | Tamanho         | Variante          |
|-------------------------------|-----------------|-------------------|
| Splash Screen                 | 200×200px       | Logo completa     |
| Top AppBar / Navbar           | altura 32px     | Logo completa     |
| Login / Onboarding            | 120×120px       | Logo completa     |
| Sidebar Admin (collapsed)     | ícone 40px      | Só o ícone "OX"   |
| Sidebar Admin (expanded)      | largura 140px   | Logo completa     |
| Favicon / PWA                 | 32×32 / 192×192 | Ícone "OX"        |

**Regra de fundo:** a logo só aparece sobre `#092F3D` ou fundos muito escuros. Nunca sobre branco ou superfícies claras — a logo já traz o fundo embutido (é um square com cantos arredondados `#092F3D`).

---

### Iconografia

- **Flutter:** `lucide_icons` (pub.dev) — linha fina, estilo moderno
- **React:** `lucide-react` — mesmo conjunto, consistência visual cross-platform

Tamanhos padrão:
- Nav icons: 24px
- Card icons: 20px
- Inline icons: 16px
- FAB icon: 28px

---

### Animações e Transições

```
Duração padrão:   200ms
Duração modal:    300ms
Curva:            easeInOut / Curves.easeInOut

Transições de página Flutter: SlideTransition (bottom → up para modais, left → right para push)
Transições React:  framer-motion fade + slide-up (100ms delay)
```

---

## Fase 11 — Flutter App Cliente

**Duração estimada: 1,5–2 semanas**
**Pasta:** `ox-app-client/`

---

### Setup e Dependências

```bash
flutter create ox_app_client --org com.oxservices --platforms android,ios
cd ox_app_client
```

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter

  # HTTP & Auth
  dio: ^5.4.0
  supabase_flutter: ^2.3.0

  # Navegação
  go_router: ^13.2.0

  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0

  # UI
  google_fonts: ^6.2.1
  lucide_icons: ^0.0.4
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  lottie: ^3.1.0

  # Funcionalidades
  image_picker: ^1.0.7
  video_player: ^2.8.3
  firebase_core: ^2.27.0
  firebase_messaging: ^14.7.19
  flutter_local_notifications: ^17.1.2
  shared_preferences: ^2.2.3
  intl: ^0.19.0
  dotted_border: ^2.1.0
  percent_indicator: ^4.2.3

dev_dependencies:
  build_runner: ^2.4.8
  riverpod_generator: ^2.3.9
  flutter_lints: ^3.0.0
```

---

### Estrutura de Pastas

```
lib/
├── main.dart
├── app.dart                        # MaterialApp + Theme + Router
├── core/
│   ├── theme/
│   │   ├── app_theme.dart          # ThemeData completo
│   │   ├── app_colors.dart         # Constantes de cor
│   │   └── app_text_styles.dart    # TextStyle nomeados
│   ├── router/
│   │   └── app_router.dart         # GoRouter com guards de auth
│   ├── api/
│   │   ├── api_client.dart         # Dio + interceptors
│   │   └── api_endpoints.dart      # Constantes de URL
│   ├── auth/
│   │   ├── auth_provider.dart      # Estado de auth (Riverpod)
│   │   └── token_storage.dart      # SharedPreferences
│   └── widgets/
│       ├── ox_button.dart          # Botão primário/secundário
│       ├── ox_card.dart            # Card padrão
│       ├── ox_input.dart           # Campo de texto estilizado
│       ├── ox_badge.dart           # Badge de status
│       ├── ox_app_bar.dart         # AppBar customizada
│       ├── ox_loading.dart         # Shimmer / skeleton
│       └── ox_empty_state.dart     # Tela vazia ilustrada
├── features/
│   ├── splash/
│   │   └── splash_screen.dart
│   ├── onboarding/
│   │   └── onboarding_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   └── auth_controller.dart    # Riverpod notifier
│   ├── projects/
│   │   ├── projects_list_screen.dart
│   │   ├── project_detail_screen.dart
│   │   ├── create_project_screen.dart
│   │   ├── project_provider.dart
│   │   └── widgets/
│   │       ├── project_card.dart
│   │       ├── phase_timeline.dart
│   │       └── status_banner.dart
│   ├── phases/
│   │   ├── phase_detail_screen.dart
│   │   ├── validate_phase_screen.dart
│   │   └── phase_provider.dart
│   └── payments/
│       ├── payment_screen.dart
│       ├── escrow_status_screen.dart
│       └── payment_provider.dart
└── assets/
    ├── logo.webp
    ├── images/
    └── lottie/
        ├── loading.json
        ├── success.json
        └── empty.json
```

---

### Tema Flutter (app_theme.dart)

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.primary,
    colorScheme: ColorScheme.dark(
      primary:    AppColors.accent,
      secondary:  AppColors.secondary,
      surface:    AppColors.surface,
      background: AppColors.primary,
      error:      AppColors.error,
      onPrimary:  AppColors.primary,   // texto sobre botão accent
      onSurface:  AppColors.secondary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.secondary),
    ),
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.divider, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.accent, width: 1.5),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.textSecondary,
    ),
  );
}
```

```dart
// app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const primary       = Color(0xFF092F3D);
  static const secondary     = Color(0xFFFFFFFF);
  static const accent        = Color(0xFF03FC30);
  static const surface       = Color(0xFF0D3F52);
  static const surface2      = Color(0xFF0A4A62);
  static const error         = Color(0xFFFF4C4C);
  static const warning       = Color(0xFFFFA500);
  static const divider       = Color(0xFF1A5570);
  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA8C4CE);
  static const textDisabled  = Color(0xFF4A7A8A);
}
```

---

### Telas — App Cliente

#### 1. Splash Screen
```
Duração: 2s
Fundo: #092F3D (tela cheia)
Centro: logo.webp animada (scale in + fade in via Lottie ou AnimatedContainer)
Após: redireciona para Onboarding (1ª vez) ou Home (autenticado)
```

#### 2. Onboarding (3 slides)

| Slide | Ícone      | Título                  | Subtexto                                |
|-------|------------|-------------------------|-----------------------------------------|
| 1     | 🏗️ (SVG)  | Crie seu projeto        | Descreva o serviço, defina fases e orçamento |
| 2     | 🤝 (SVG)  | Encontramos o profissional | Matching automático com trabalhadores certificados |
| 3     | ✅ (SVG)  | Pague com segurança     | Escrow libera o valor só após sua aprovação |

```
Layout: fundo #092F3D, ilustração centralizada (SVG ou Lottie),
        dots de progresso em #03FC30 (ativo) / #1A5570 (inativo),
        botão "Continuar" primário (#03FC30),
        botão "Pular" textual (#A8C4CE)
```

#### 3. Login

```
┌─────────────────────────────┐
│  [logo.webp]   100x100      │
│                             │
│  Bem-vindo de volta         │  ← displayMedium branco
│  Entre na sua conta OX      │  ← bodyMedium #A8C4CE
│                             │
│  ┌─────────────────────┐    │
│  │  E-mail             │    │  ← OxInput
│  └─────────────────────┘    │
│  ┌─────────────────────┐    │
│  │  Senha          👁  │    │  ← OxInput com toggle
│  └─────────────────────┘    │
│                             │
│  [     Entrar          ]    │  ← OxButton primário (#03FC30)
│                             │
│  ─────── ou ───────         │
│                             │
│  [  Entrar com Google  ]    │  ← OxButton secundário
│                             │
│  Não tem conta? Cadastre-se │  ← link em #03FC30
└─────────────────────────────┘
```

#### 4. Cadastro

```
Campos: Nome completo, E-mail, Senha, Confirmar senha
Radio: Sou cliente / Sou trabalhador  ← selecionar role
Botão: "Criar conta" primário
Link: "Já tenho conta"
```

#### 5. Home — Lista de Projetos

```
┌─────────────────────────────┐
│ [logo 32px]    João   [🔔]  │  ← AppBar customizada
├─────────────────────────────┤
│  Meus Projetos              │
│  3 projetos ativos          │  ← subtítulo #A8C4CE
│                             │
│  [Todos][Ativos][Fechados]  │  ← Filter chips
│                             │
│  ┌─────────────────────┐    │
│  │ Instalação Elétrica │    │  ← ProjectCard
│  │ ●Em execução        │    │  ← badge verde
│  │ Fase 2/4 ▓▓▓░░     │    │  ← ProgressBar accent
│  │ € 2.400  · 15 dias  │    │
│  └─────────────────────┘    │
│  ┌─────────────────────┐    │
│  │ Pintura Exterior    │    │
│  │ ●Aguardando match   │    │  ← badge laranja
│  │ Fase 0/3 ░░░        │    │
│  │ € 800   · 8 dias    │    │
│  └─────────────────────┘    │
│                             │
│            [+]              │  ← FAB #03FC30
└─────────────────────────────┘
```

#### 6. Criar Projeto

```
Tela em scroll — stepper de 3 etapas:

Etapa 1 — Informações básicas
  - Título do projeto (input)
  - Descrição (textarea)
  - Localização (input + ícone mapa)
  - Orçamento total (input numérico com € prefix)
  - Prazo (date picker)

Etapa 2 — Fases do projeto
  - Lista de fases adicionadas (card arrastável para reordenar)
  - Botão "+ Adicionar Fase"
  - Cada fase: nome + valor estimado

Etapa 3 — Revisão
  - Resumo completo
  - Botão "Criar Projeto" → POST /projects
```

#### 7. Detalhe do Projeto

```
┌─────────────────────────────┐
│ ← Instalação Elétrica       │  ← AppBar com back
│   Em Execução  ●            │  ← badge dinâmico
├─────────────────────────────┤
│ INFORMAÇÕES                 │
│ Trabalhador: Carlos Silva   │
│ Valor Total: € 2.400        │
│ Prazo: 15/06/2026           │
├─────────────────────────────┤
│ FASES  (timeline vertical)  │
│                             │
│ ✅ Fase 1 — Preparação      │  ← verde, validada
│    Concluída em 10/05       │
│                             │
│ ⟳  Fase 2 — Fiação          │  ← laranja, em revisão
│    Evidências enviadas       │
│    [Ver fotos] [Aprovar] [Rejeitar] │
│                             │
│ ⏸  Fase 3 — Quadro Elétrico │  ← cinza, pendente
│ ⏸  Fase 4 — Testes Finais   │  ← cinza, pendente
├─────────────────────────────┤
│ PAGAMENTO                   │
│ Escrow: € 2.400 bloqueado   │
│ Liberado: € 600 (Fase 1)    │
│ [Ver detalhes financeiros]  │
└─────────────────────────────┘
```

#### 8. Validar Fase (modal bottom sheet ou tela full)

```
┌─────────────────────────────┐
│ Validar — Fase 2: Fiação    │
├─────────────────────────────┤
│ EVIDÊNCIAS DO TRABALHADOR   │
│ ┌───┐ ┌───┐ ┌───┐ ┌───┐   │  ← grid de fotos
│ │📷│ │📷│ │📷│ │📷│   │     tap → fullscreen
│ └───┘ └───┘ └───┘ └───┘   │
│                             │
│ Enviado em: 12/05 às 14:23  │
│                             │
│ [  ✓ Aprovar Fase   ]       │  ← OxButton primário green
│ [  ✗ Rejeitar Fase  ]       │  ← OxButton com border red
│                             │
│ Ao aprovar, € 600 será      │
│ liberado ao trabalhador.    │  ← aviso legal
└─────────────────────────────┘
```

---

### Navegação — App Cliente (GoRouter)

```dart
final routes = [
  GoRoute(path: '/splash',      builder: SplashScreen),
  GoRoute(path: '/onboarding',  builder: OnboardingScreen),
  GoRoute(path: '/login',       builder: LoginScreen),
  GoRoute(path: '/register',    builder: RegisterScreen),
  ShellRoute(  // BottomNav
    builder: MainShell,
    routes: [
      GoRoute(path: '/home',             builder: ProjectsListScreen),
      GoRoute(path: '/projects/new',     builder: CreateProjectScreen),
      GoRoute(path: '/projects/:id',     builder: ProjectDetailScreen),
      GoRoute(path: '/phases/:id',       builder: PhaseDetailScreen),
      GoRoute(path: '/payments/:id',     builder: PaymentScreen),
      GoRoute(path: '/profile',          builder: ProfileScreen),
    ],
  ),
];

// Guard: redireciona /home → /login se não autenticado
redirect: (context, state) {
  final isAuth = ref.read(authProvider).isAuthenticated;
  if (!isAuth && !publicRoutes.contains(state.location)) return '/login';
  return null;
}
```

---

### Bottom Navigation — App Cliente

```
Tab 1: 🏠 Projetos     (ícone: folder)
Tab 2: 🔔 Notificações (ícone: bell, badge com contador)
Tab 3: 👤 Perfil       (ícone: user)

Barra:  fundo #0D3F52, ativo #03FC30, inativo #4A7A8A
```

---

## Fase 12 — Flutter App Trabalhador

**Duração estimada: 1 semana**
**Pasta:** `ox-app-worker/`

> Mesmo Design System da Fase 11. Reuse os arquivos de `core/theme/` e `core/widgets/` — crie uma lib compartilhada ou copie e mantenha sincronizado.

---

### Setup

```bash
flutter create ox_app_worker --org com.oxservices --platforms android,ios
# Copiar: pubspec.yaml (mesmas dependências)
# Copiar: lib/core/theme/ e lib/core/widgets/
# Copiar: assets/logo.webp
```

---

### Diferenças Visuais em relação ao App Cliente

| Elemento            | App Cliente             | App Trabalhador              |
|---------------------|-------------------------|------------------------------|
| Cor de acento extra | —                       | Badge "Disponível" → #03FC30 |
| Tela principal      | Lista de projetos       | Dashboard de jobs             |
| FAB principal       | "+ Criar Projeto"       | Não tem (recebe jobs)         |
| Ação primária       | "Aprovar fase"          | "Enviar evidências"           |
| Status relevante    | "Em revisão", "Validado"| "Aceito", "Em execução"       |

---

### Estrutura de Pastas

```
lib/
├── main.dart
├── app.dart
├── core/                          # idêntico ao app cliente
│   ├── theme/
│   ├── router/
│   ├── api/
│   ├── auth/
│   └── widgets/
├── features/
│   ├── splash/
│   ├── auth/                      # idêntico
│   ├── jobs/
│   │   ├── jobs_dashboard_screen.dart   # Home do worker
│   │   ├── job_detail_screen.dart
│   │   ├── job_accept_screen.dart       # confirmar aceite
│   │   └── jobs_provider.dart
│   ├── execution/
│   │   ├── phase_execution_screen.dart  # tela ativa durante trabalho
│   │   ├── upload_evidence_screen.dart  # câmera + galeria
│   │   ├── checklist_screen.dart        # checklist da fase
│   │   └── execution_provider.dart
│   ├── payments/
│   │   ├── payments_history_screen.dart
│   │   └── stripe_onboarding_screen.dart  # setup conta Stripe
│   └── profile/
│       ├── worker_profile_screen.dart
│       └── rating_history_screen.dart
└── assets/
    ├── logo.webp
    └── lottie/
```

---

### Telas — App Trabalhador

#### 1. Dashboard (Home)

```
┌─────────────────────────────┐
│ [logo 32px]   Carlos   [🔔] │
├─────────────────────────────┤
│  ●  Disponível              │  ← toggle on/off (verde / cinza)
│  Sua avaliação: ⭐ 4.8       │
│                             │
│  JOBS DISPONÍVEIS PARA VOCÊ │
│                             │
│  ┌─────────────────────┐    │
│  │ Instalação Elétrica │    │
│  │ Lisboa · € 1.680    │    │
│  │ Prazo: 20 dias      │    │
│  │ Match: ████░ 87%    │    │  ← barra de compatibilidade
│  │ [Ver detalhes]      │    │  ← botão outline
│  └─────────────────────┘    │
│                             │
│  MEUS JOBS ATIVOS           │
│                             │
│  ┌─────────────────────┐    │
│  │ Pintura Exterior    │    │
│  │ ●Em execução · Fase 2│   │
│  │ [Continuar]         │    │  ← botão primário #03FC30
│  └─────────────────────┘    │
└─────────────────────────────┘
```

#### 2. Detalhe do Job (antes de aceitar)

```
┌─────────────────────────────┐
│ ← Instalação Elétrica       │
│   Lisboa, Portugal          │
├─────────────────────────────┤
│ DESCRIÇÃO DO PROJETO        │
│ [texto completo]            │
│                             │
│ FASES E PAGAMENTOS          │
│ Fase 1 — Preparação  € 400  │
│ Fase 2 — Fiação      € 800  │
│ Fase 3 — Quadro      € 480  │
│ ─────────────────────────── │
│ Total               € 1.680 │
│                             │
│ PRAZO: 20 dias              │
│ LOCAL: Lisboa, Bairro Alto  │
│                             │
│ [   Aceitar Job     ]       │  ← primário #03FC30
│ [   Recusar         ]       │  ← outline vermelho
└─────────────────────────────┘
```

#### 3. Execução de Fase

```
┌─────────────────────────────┐
│ ← Fase 2: Fiação            │
│   Em Execução               │
├─────────────────────────────┤
│ CHECKLIST DA FASE           │
│ ☑ Materiais separados       │
│ ☑ EPI's utilizados          │
│ ☐ Fiação passada            │  ← checkbox interativo
│ ☐ Conexões verificadas      │
│ ☐ Teste de tensão           │
│                             │
│ EVIDÊNCIAS (0/3 obrigatórias)│
│ ┌─────────────────────────┐ │
│ │  + Adicionar foto/vídeo │ │  ← área de upload
│ └─────────────────────────┘ │
│ (tirar foto) (da galeria)   │
│                             │
│ [  Enviar para Revisão  ]   │  ← desabilitado até 3 evidências
└─────────────────────────────┘
```

#### 4. Upload de Evidências

```
Layout de câmera com overlay OX:
- Preview da câmera a tela cheia
- Barra inferior #092F3D semi-transparente
- Botão de captura: círculo branco, tap → foto
- Botão de galeria: ícone a esquerda
- Contador: "2 de 3 fotos" em #03FC30
- Botão confirmar (check verde) quando mínimo atingido
```

#### 5. Histórico de Pagamentos

```
┌─────────────────────────────┐
│ Meus Pagamentos             │
│ Total recebido: € 4.200     │  ← destaque em #03FC30
│                             │
│ MAIO 2026                   │
│ ┌─────────────────────┐     │
│ │ ✓ Instalação Elétrica│    │
│ │   Fase 2 concluída   │    │
│ │   + € 560  14/05    │     │  ← valor em verde
│ └─────────────────────┘     │
│ ┌─────────────────────┐     │
│ │ ✓ Pintura Exterior  │     │
│ │   Projeto concluído │     │
│ │   + € 840  08/05    │     │
│ └─────────────────────┘     │
└─────────────────────────────┘
```

---

### Bottom Navigation — App Trabalhador

```
Tab 1: 💼 Jobs        (ícone: briefcase)
Tab 2: ⚡  Em Execução (ícone: zap — jobs ativos)
Tab 3: 💰 Pagamentos  (ícone: wallet)
Tab 4: 👤 Perfil      (ícone: user)
```

---

## Fase 13 — React Admin Panel

**Duração estimada: 1 semana**
**Pasta:** `ox-admin/`
**Stack:** Next.js 14 (App Router) + TypeScript + Tailwind CSS

---

### Setup

```bash
npx create-next-app@latest ox-admin \
  --typescript --tailwind --app \
  --no-src-dir --import-alias "@/*"

cd ox-admin

npm install axios @tanstack/react-query @tanstack/react-query-devtools
npm install recharts lucide-react
npm install @supabase/supabase-js
npm install date-fns
npm install clsx tailwind-merge        # utilitários de className
npm install framer-motion              # animações
npm install react-hot-toast            # notificações

npm install -D @types/node
```

---

### Tailwind Config (cores OX)

```js
// tailwind.config.ts
const config = {
  theme: {
    extend: {
      colors: {
        primary:    '#092F3D',
        secondary:  '#FFFFFF',
        accent:     '#03FC30',
        surface:    '#0D3F52',
        surface2:   '#0A4A62',
        error:      '#FF4C4C',
        warning:    '#FFA500',
        divider:    '#1A5570',
        'text-secondary': '#A8C4CE',
        'text-disabled':  '#4A7A8A',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
      },
      borderRadius: {
        card: '16px',
        btn:  '12px',
        input: '12px',
      },
    },
  },
};
```

---

### Estrutura de Pastas (Next.js App Router)

```
app/
├── (auth)/
│   └── login/
│       └── page.tsx
├── (dashboard)/
│   ├── layout.tsx               # Sidebar + Header
│   ├── page.tsx                 # redirect → /projects
│   ├── projects/
│   │   ├── page.tsx             # lista
│   │   └── [id]/
│   │       └── page.tsx         # detalhe
│   ├── workers/
│   │   ├── page.tsx
│   │   └── [id]/
│   │       └── page.tsx
│   ├── payments/
│   │   └── page.tsx
│   └── matching/
│       └── [projectId]/
│           └── page.tsx
├── layout.tsx                   # RootLayout (fonts, providers)
└── globals.css

components/
├── ui/
│   ├── Button.tsx               # variantes: primary, secondary, ghost, danger
│   ├── Card.tsx
│   ├── Input.tsx
│   ├── Badge.tsx                # status badge
│   ├── Table.tsx                # tabela estilizada
│   ├── Modal.tsx
│   ├── Skeleton.tsx
│   └── Toast.tsx
├── layout/
│   ├── Sidebar.tsx
│   ├── Header.tsx
│   └── PageHeader.tsx
└── features/
    ├── projects/
    │   ├── ProjectsTable.tsx
    │   ├── ProjectStatusSelect.tsx
    │   └── PhaseTimeline.tsx
    ├── workers/
    │   ├── WorkersTable.tsx
    │   └── WorkerRatingStars.tsx
    ├── payments/
    │   └── PaymentsChart.tsx
    └── matching/
        └── CandidatesCard.tsx

lib/
├── api.ts                       # axios instance
├── auth.ts                      # Supabase auth helpers
├── queries/                     # React Query hooks
│   ├── useProjects.ts
│   ├── useWorkers.ts
│   └── usePayments.ts
└── utils/
    ├── cn.ts                    # clsx + twMerge
    ├── formatCurrency.ts
    └── formatDate.ts
```

---

### Layout Principal (Sidebar + Header)

```
┌──────────┬──────────────────────────────────────────┐
│          │  Header                                  │
│ Sidebar  │  [Título da página]      [Admin] [🔔]    │
│          ├──────────────────────────────────────────┤
│ [logo]   │                                          │
│          │  Conteúdo da página                      │
│ ● Projetos│                                         │
│   Workers│                                          │
│   Pagamentos                                        │
│   Matching│                                         │
│          │                                          │
│ [Sair]   │                                          │
└──────────┴──────────────────────────────────────────┘
```

**Sidebar (expandida — 240px / colapsada — 64px):**
```
Fundo: #092F3D
Borda direita: 1px solid #1A5570
Logo: logo.webp (expanded) | ícone OX (collapsed)

Nav items:
  - ícone (24px, #A8C4CE inativo / #03FC30 ativo)
  - label (14px semibold, branco ativo / #A8C4CE inativo)
  - hover: background #0D3F52
  - ativo: background rgba(3,252,48,0.1) + borda esquerda 3px #03FC30
```

**Header:**
```
Fundo: #092F3D
Altura: 64px
Borda inferior: 1px solid #1A5570
Conteúdo: [título da página | breadcrumb] + [avatar admin + nome]
```

---

### Páginas — Admin Panel

#### 1. Login (`/login`)

```
┌─────────────────────────────────────┐
│  [logo.webp 120px centralizado]     │
│  Painel Administrativo OX           │
│  Acesso restrito a administradores  │
│                                     │
│  ┌─────────────────────────────┐    │
│  │ E-mail                      │    │
│  └─────────────────────────────┘    │
│  ┌─────────────────────────────┐    │
│  │ Senha                    👁 │    │
│  └─────────────────────────────┘    │
│                                     │
│  [       Entrar no Painel      ]    │  ← botão #03FC30
└─────────────────────────────────────┘

Fundo: #092F3D tela cheia
Card central: #0D3F52, max-w-md, rounded-card, padding 40px
```

#### 2. Lista de Projetos (`/projects`)

```
┌──────────────────────────────────────────────────┐
│ Projetos                         [Exportar CSV]  │
├──────────────────────────────────────────────────┤
│ Busca: [___________]  Status: [▼ Todos]  [Filtrar]│
├──────────────────────────────────────────────────┤
│ # │ Título              │ Cliente    │ Status       │ Valor   │ Data    │ Ações │
│ 1 │ Instalação Elétrica │ João Silva │ ●Em execução │ €2.400  │ 01/05   │ [Ver] │
│ 2 │ Pintura Exterior    │ Maria C.   │ ●Em validação│ €800    │ 28/04   │ [Ver] │
│ 3 │ Redes               │ Pedro A.   │ ●Rascunho    │ €1.200  │ 25/04   │ [Ver] │
├──────────────────────────────────────────────────┤
│                          ← 1 2 3 ... →           │
└──────────────────────────────────────────────────┘
```

#### 3. Detalhe do Projeto (`/projects/[id]`)

```
Seção superior: informações + status selector (admin pode mudar manualmente)
Seção meio: timeline de fases com evidências (galeria de fotos inline)
Seção inferior: contrato, escrow, histórico de transações
Botões de ação: [Aprovar] [Rejeitar] [Atribuir Worker] [Forçar Status]
```

#### 4. Workers (`/workers`)

```
Cards em grid (3 colunas) ou tabela — toggle de visualização

Card worker:
  - Avatar (placeholder com inicial)
  - Nome + rating (⭐ 4.8)
  - Skills como chips
  - Badge: Disponível / Ocupado / Inativo
  - Botão: Ver perfil completo

Tabela worker:
  Colunas: Nome | Skills | Rating | Projetos concluídos | Status | Ações
```

#### 5. Detalhe do Worker (`/workers/[id]`)

```
Header: avatar + nome + rating + toggle disponibilidade (admin pode forçar)
Tabs:
  - Perfil (skills, certificações, conta Stripe)
  - Histórico de Jobs (tabela)
  - Avaliações recebidas (cards com comentários)
  - Financeiro (transferências Stripe)
```

#### 6. Pagamentos (`/payments`)

```
Topo: 3 KPI cards
  ┌─────────┐  ┌─────────┐  ┌─────────┐
  │ Total   │  │Liberado │  │Em Escrow│
  │€ 42.800 │  │€ 31.200 │  │€ 11.600 │
  │ este mês│  │         │  │         │
  └─────────┘  └─────────┘  └─────────┘

Meio: Gráfico de barras (recharts) — pagamentos por semana
  Barras: #03FC30 (liberado) + #0D3F52 borda (em escrow)

Baixo: Tabela de transações
  Contrato | Worker | Valor | Split 70/20/10 | Status | Data
```

#### 7. Matching (`/matching/[projectId]`)

```
Esquerda: Card do projeto (resumo + skills necessárias)
Direita: Lista de candidatos ordenados por match %

Candidato card:
  - Nome + foto
  - Barra de match: ████░ 87%  (cor #03FC30)
  - Skills em comum: chips verdes
  - Skills faltando: chips cinza
  - Rating: ⭐ 4.8
  - [Atribuir este Worker] → POST /matching + /contracts
```

---

### Componentes React Chave

#### Button.tsx

```tsx
type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'danger';

// primary:   bg-accent text-primary font-semibold
// secondary: border border-white text-white bg-transparent
// ghost:     text-text-secondary hover:text-white hover:bg-surface
// danger:    bg-error/10 text-error border border-error
```

#### Badge.tsx

```tsx
const statusConfig = {
  draft:           { label: 'Rascunho',      className: 'bg-white/10 text-text-secondary' },
  in_validation:   { label: 'Em Validação',  className: 'bg-warning/15 text-warning' },
  matched:         { label: 'Match feito',   className: 'bg-accent/15 text-accent' },
  contract_signed: { label: 'Contrato ass.', className: 'bg-accent/15 text-accent' },
  active_escrow:   { label: 'Escrow ativo',  className: 'bg-accent/15 text-accent' },
  in_execution:    { label: 'Em execução',   className: 'bg-accent/20 text-accent font-semibold' },
  closing:         { label: 'Encerrando',    className: 'bg-warning/15 text-warning' },
  closed:          { label: 'Concluído',     className: 'bg-accent/15 text-accent' },
  rejected:        { label: 'Rejeitado',     className: 'bg-error/15 text-error' },
};
```

---

## Checklist de Consistência Visual

Use este checklist antes de marcar qualquer fase como concluída:

### Design

- [ ] Fundo principal é sempre `#092F3D`
- [ ] Cards usam `#0D3F52` (nunca branco sobre primário)
- [ ] Botões primários são `#03FC30` com texto `#092F3D` bold
- [ ] Fonte é Inter em todas as plataformas
- [ ] Bordas de inputs: normal `#1A5570`, focus `#03FC30`
- [ ] Status badges seguem a tabela de cores definida
- [ ] Ícones são do Lucide (mesmo conjunto no Flutter e React)

### Logo

- [ ] Splash Screen tem logo centralizada animada
- [ ] AppBar / Sidebar contém logo (ou ícone em modo colapsado)
- [ ] Login tem logo em destaque
- [ ] Logo nunca aparece sobre fundo claro

### Comportamento

- [ ] Estados de loading têm Skeleton / Shimmer (nunca spinner simples)
- [ ] Ações destrutivas (rejeitar, excluir) têm confirmação modal
- [ ] Erros da API mostram Toast com mensagem legível
- [ ] Formulários têm validação inline (vermelho + mensagem abaixo)
- [ ] Telas vazias têm ilustração + CTA (não só texto)

### Acessibilidade

- [ ] Contraste de texto ≥ 4.5:1 (verificar #A8C4CE sobre #092F3D)
- [ ] Botões têm mínimo 48px de área de toque (Flutter)
- [ ] Campos de formulário têm labels visíveis (não só placeholder)
- [ ] Estados de foco visíveis (outline `#03FC30`)

---

## Ordem de Implementação Recomendada

```
Semana 1:  Design System (theme, widgets base) → Splash → Auth (Fase 11)
Semana 2:  Projetos list/detalhe/criar → Fases → Validação (Fase 11)
Semana 3:  App Worker: jobs dashboard → aceite → execução → upload (Fase 12)
Semana 4:  Admin: login → sidebar → projetos list/detalhe → workers (Fase 13)
Semana 5:  Admin: payments → matching → KPIs → refinamento geral
```

---

## Internacionalização (i18n)

> **Não é necessário implementar agora.** A estrutura abaixo é um guia para quando for a hora — o importante é que o código das Fases 11, 12 e 13 seja escrito de forma i18n-ready (sem strings hardcoded nas UIs).

### Idiomas alvo

| Código | Idioma    | Prioridade |
|--------|-----------|------------|
| `pt`   | Português | Idioma padrão (MVP) |
| `en`   | Inglês    | ⏳ Pós-MVP  |
| `nl`   | Holandês  | ⏳ Pós-MVP  |

### Preparação desde já (obrigatório nas Fases 11–13)

O único trabalho obrigatório agora é **não hardcodar strings na UI**. Centralize todos os textos em arquivos de tradução, mesmo que só exista o português por enquanto.

#### Flutter — usar `flutter_localizations` + `intl`

```bash
flutter pub add flutter_localizations --sdk=flutter
flutter pub add intl
```

```yaml
# pubspec.yaml
flutter:
  generate: true  # habilita geração automática de ARB

# l10n.yaml (na raiz do projeto)
arb-dir: lib/l10n
template-arb-file: app_pt.arb
output-localization-file: app_localizations.dart
```

```json
// lib/l10n/app_pt.arb  (único arquivo necessário agora)
{
  "@@locale": "pt",
  "appName": "OX Services",
  "loginTitle": "Bem-vindo de volta",
  "loginSubtitle": "Entre na sua conta OX",
  "loginEmailLabel": "E-mail",
  "loginPasswordLabel": "Senha",
  "loginButton": "Entrar",
  "projectsTitle": "Meus Projetos",
  "projectsActive": "{count} projetos ativos",
  "@projectsActive": {
    "placeholders": { "count": { "type": "int" } }
  }
}

// lib/l10n/app_en.arb  (criar vazio por agora — preencher no pós-MVP)
// lib/l10n/app_nl.arb  (criar vazio por agora — preencher no pós-MVP)
```

```dart
// Uso no widget (nunca string literal):
Text(AppLocalizations.of(context)!.loginTitle)

// NUNCA fazer:
Text('Bem-vindo de volta')  // ← hardcoded, dificulta i18n
```

#### React Admin — usar `next-intl`

```bash
npm install next-intl
```

```
messages/
  pt.json   ← único arquivo necessário agora
  en.json   ← criar vazio por agora
  nl.json   ← criar vazio por agora
```

```json
// messages/pt.json
{
  "nav": {
    "projects": "Projetos",
    "workers": "Trabalhadores",
    "payments": "Pagamentos",
    "matching": "Matching"
  },
  "projects": {
    "title": "Projetos",
    "exportCsv": "Exportar CSV",
    "statusFilter": "Status"
  }
}
```

```tsx
// Uso no componente:
import { useTranslations } from 'next-intl';

export default function ProjectsPage() {
  const t = useTranslations('projects');
  return <h1>{t('title')}</h1>;

  // NUNCA: <h1>Projetos</h1>
}
```

### O que fazer no pós-MVP (quando for implementar)

```
1. Preencher app_en.arb e app_nl.arb (Flutter) — traduzir todas as chaves do pt.arb
2. Preencher en.json e nl.json (React) — traduzir todas as chaves do pt.json
3. Flutter: adicionar locale switcher nas configurações do perfil
4. React Admin: adicionar seletor de idioma no header
5. Testar RTL (holandês e inglês são LTR — sem problema)
6. Testar formatação de datas e moedas por locale (intl / date-fns locale)
   - pt: "14 de maio de 2026" · €2.400,00
   - en: "May 14, 2026"      · €2,400.00
   - nl: "14 mei 2026"       · €2.400,00
```


____________
O backend está em ótimo estado. Aqui está o diagnóstico completo:

Situação geral: pronto para consumir
Todos os módulos essenciais existem, estão registrados e têm rotas funcionais:

Módulo	Rotas disponíveis	Status
Auth	POST /auth/sync, GET /auth/me	✅
Projects	CRUD completo + PATCH /status	✅
Phases	List, detail, status, validate, evidence upload/list	✅
Contracts	Create, sign, get by project	✅
Payments	Escrow create/capture/release, Stripe onboarding	✅
Workers	GET/PATCH /workers/me, list (admin), get by id	✅
Matching	GET /matching/:projectId/candidates	✅
Users	PATCH /users/fcm-token	✅
Webhooks	POST /webhooks/stripe	✅
Auth JWT Supabase está funcionando end-to-end com RBAC por role (client, worker, admin). Swagger está ativo em /api/docs — pode usar para consultar os contratos exatos enquanto desenvolve o frontend.

3 lacunas que vão aparecer ao desenvolver
Estas rotas não existem ainda e serão necessárias durante as fases 11–13:

O que falta	Quem precisa	Impacto
GET /payments — listagem de transações	Admin (Fase 13, tela de pagamentos)	Médio
GET /workers/me/ratings — avaliações do worker	App Trabalhador (Fase 12, tela de perfil)	Baixo
POST /matching/:projectId/assign — atribuir worker manualmente	Admin (Fase 13, tela de matching)	Médio
Nada crítico para começar — as lacunas só aparecem em telas específicas, não no fluxo principal. Quando chegar nelas, adicionamos os endpoints no backend em minutos.

Uma discrepância de rota a corrigir
O ox-passo-a-passo.md documenta POST /matching/:projectId mas o backend implementou GET /matching/:projectId/candidates. Quando for consumir no frontend, use a rota real do backend (o Swagger vai mostrar a correta).

Conclusão: pode começar a Fase 11 agora sem bloqueios. O fluxo completo — login → criar projeto → fases → validar → pagamento — tem cobertura total no backend.





____________
---

*OX Field Services · Frontend Plan · v1.1 · Fases 11–13*
