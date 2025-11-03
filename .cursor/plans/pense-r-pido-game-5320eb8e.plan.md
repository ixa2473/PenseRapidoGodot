<!-- 5320eb8e-a2e4-41d8-8ece-a3da0ec4c918 93ff08d6-d8ab-43bd-9f5c-e0f290c71b05 -->
# Pense Rápido! - Educational Game Implementation (Updated from Prototype)

## Project Structure

Create a Godot 4.x project with the following structure:

```
/scenes/
 - MainMenu.tscn (card-based navigation)
 - Tutorial.tscn
 - DifficultySelect.tscn (unified for both modes)
 - Gameplay.tscn (handles both math and language)
 - ExplanationPopup.tscn (overlay)
/scripts/
 - Global.gd (autoload for game state)
 - MainMenu.gd
 - Tutorial.gd
 - DifficultySelect.gd
 - Gameplay.gd
 - GrowingItem.gd
 - ExplanationPopup.gd
/data/
 - math_questions.json
 - language_questions.json
/assets/
 - /fonts/
 - /audio/
 - /images/
```

## Core Systems (Based on Prototype)

### 1. Global State Manager (Global.gd)

- Autoload singleton to manage game state
- Track current mode (math/language), difficulty (FÁCIL/MÉDIO/DIFÍCIL)
- Store high score (save/load from user:// directory)
- Manage audio settings (sound on/off from Options)
- Lives system: 3 lives per game
- Phase progression: 7 phases per difficulty
- Constants for difficulty settings (time limits, growth speeds, age ranges)

### 2. Main Menu Scene (Card-based Navigation)

**Layout (from prototype sketch 1):**

- Title: "Pense Rápido!" with version "ver 1.00"
- Three cards displayed horizontally: "TUTORIAL", "JOGAR", "OPÇÕES"
- Navigation arrows (< >) on sides to cycle through cards
- Currently selected card highlighted/centered
- Bottom: "SPACE CONFIRMAR" prompt

**Controls:**

- Left/Right Arrow keys: Navigate between cards
- Space: Confirm selection
- Cards: Tutorial, Play (Jogar), Options (Opções)

**Functionality:**

- Tutorial card → Tutorial scene
- Jogar card → Difficulty Selection scene
- Opções card → Options menu (sound toggle, etc.)

### 3. Tutorial Scene

- Explains game mechanics
- Shows how to answer questions
- Keyboard controls guide
- Space to continue, Shift to go back

### 4. Difficulty Selection Scene (Unified for Both Modes)

**Layout (from prototype sketch 2):**

- Title: "Pense Rápido! ver 1.00" with logo indicator
- Three difficulty cards displayed horizontally with sample content:
                                                                - **FÁCIL**: Shows "2+2", "1+4", "Idade: 6-7"
                                                                - **MÉDIO**: Shows "7×3", "18÷2", "Idade: 7-8"
                                                                - **DIFÍCIL**: Shows "Jícara", "Sedex", "Idade: 9"
- Navigation arrows (< >) on sides
- Currently selected difficulty highlighted

**Bottom buttons:**

- "Shift VOLTAR" (back to main menu)
- "↓ MUDAR PARA PORTA" / "↓ MUDAR PARA MAT" (toggle between Math/Portuguese mode)
- "SPACE COMEÇAR!" (start game)

**Controls:**

- Left/Right Arrow: Navigate difficulty cards
- Down Arrow: Toggle between Math and Language mode
- Space: Start game with selected difficulty and mode
- Shift: Return to main menu

**Visual feedback:**

- Cards show representative sample questions for each difficulty
- Age range displayed on each card
- Math mode shows equations, Language mode shows words

### 5. Gameplay Scene (Unified for Math and Language)

**UI Layout (from prototype sketches 3 & 4):**

**Top Section:**

- Top-left: Phase indicators - 7 boxes showing progression (boxes 1-7, current phase highlighted)
- Top-right info panel:
                                                                - "Modo FÁCIL/MÉDIO/DIFÍCIL"
                                                                - Player icon with "×3" (lives remaining)
                                                                - "Dificuldade" indicator
                                                                - "Vidas" display
                                                                - "Pergunta" label

**Center:**

- Large growing item (equation/word) that scales up over time
- Starts small, grows to fill center area
- Example: "7 × 3" in large text

**Bottom:**

- Input area with cursor indicator "I"
- Text: "ESPAÇO PARA DIGITAR"
- Answer input field (for typing numbers or text)

**Gameplay Mechanics:**

1. **Phase System**: 7 phases per game (visible at top)
2. **Lives System**: 3 lives (shown as "×3")

                                                                                                - Lose a life on wrong answer or timeout
                                                                                                - Game over when lives reach 0

3. **Growing Question**:

                                                                                                - Question appears small in center
                                                                                                - Grows gradually over time (scale animation)
                                                                                                - Growth speed based on difficulty

4. **Answer Input**:

                                                                                                - Press Space to activate input field
                                                                                                - Type answer (numbers for math, words/options for language)
                                                                                                - Press Enter to submit

5. **Wrong Answer Handling** (from sketch 4):

                                                                                                - Shows correct answer (e.g., "21" for "7 × 3")
                                                                                                - Displays explanation popup
                                                                                                - Options: "Shift DESISTIR", "↓ EXPLICAÇÃO", "SPACE CONTINUAR!"

**Math Mode Question Types:**

- **Equation**: "7 × 3" → player types "21" and enter to confirm answer
- **Reverse**: Show target and operator, fill in operands

**Language Mode Question Types:**

- Word classification (verbo, substantivo, etc.)
- Tonic syllable identification
- Spelling choices (SS vs SC, Ç vs S)
- Prosody classification (proparoxítona, etc.)

### 6. Explanation Popup (Overlay)

**Triggered on wrong answer:**

- Shows question that was missed
- Displays correct answer prominently
- Optional explanation text for why

**Controls (from sketch 4):**

- Down Arrow: Toggle detailed explanation
- Space: Continue to next question
- Shift: Give up / return to menu

### 7. Game Over / Victory Scene

**Victory Condition:**

- Complete all 7 phases with remaining lives

**Defeat Condition:**

- Lives reach 0

**Display:**

- Final score
- Phases completed
- Accuracy statistics
- New high score indication (if achieved)

**Options:**

- "SPACE CONTINUAR!" (play again same settings)
- "Shift VOLTAR" (return to main menu)

## Data Files Structure

### math_questions.json

```json
{
  "facil": {
    "age_range": "6-7",
    "phases": 7,
    "questions": [
      {"type": "equation", "text": "2 + 2", "answer": 4},
      {"type": "equation", "text": "1 + 4", "answer": 5},
      {"type": "equation", "text": "3 + 3", "answer": 6}
    ]
  },
  "medio": {
    "age_range": "7-8",
    "phases": 7,
    "questions": [
      {"type": "equation", "text": "7 × 3", "answer": 21},
      {"type": "equation", "text": "18 ÷ 2", "answer": 9}
    ]
  },
  "dificil": {
    "age_range": "9",
    "phases": 7,
    "questions": [
      {"type": "equation", "text": "12 × 8", "answer": 96},
      {"type": "equation", "text": "144 ÷ 12", "answer": 12}
    ]
  }
}
```

### language_questions.json

```json
{
  "facil": {
    "age_range": "6-7",
    "phases": 7,
    "questions": [
      {
        "type": "word",
        "text": "casa",
        "question": "É substantivo?",
        "answer": "sim"
      }
    ]
  },
  "medio": {
    "age_range": "7-8",
    "questions": [...]
  },
  "dificil": {
    "age_range": "9",
    "questions": [
      {"type": "word", "text": "Jícara", "question": "..."},
      {"type": "word", "text": "Sedex", "question": "..."}
    ]
  }
}
```

## Difficulty Settings

**FÁCIL (Age 6-7):**

- Phases: 7
- Lives: 3
- Growth speed: 8 seconds per question
- Math: Single-digit addition/subtraction (2+2, 1+4)
- Language: Basic word recognition

**MÉDIO (Age 7-8):**

- Phases: 7
- Lives: 3
- Growth speed: 6 seconds per question
- Math: Multiplication tables, simple division (7×3, 18÷2)
- Language: Grammar classification

**DIFÍCIL (Age 9+):**

- Phases: 7
- Lives: 3
- Growth speed: 4 seconds per question
- Math: Larger numbers, complex operations
- Language: Advanced words (Jícara, Sedex), complex grammar

## Keyboard Controls System

**Main Menu:**

- Left/Right Arrow: Navigate cards
- Space: Confirm selection

**Difficulty Select:**

- Left/Right Arrow: Navigate difficulty
- Down Arrow: Toggle Math/Language mode
- Space: Start game
- Shift: Back to menu

**Gameplay:**

- Space: Activate input / Submit answer
- Type: Enter answer
- Enter: Submit answer
- Shift: Give up (show pause menu)

**Explanation Popup:**

- Down Arrow: Toggle detailed explanation
- Space: Continue
- Shift: Return to menu

## Audio System

**Music:**

- Menu background music (looped)
- Gameplay music (looped, different from menu)

**Sound Effects:**

- Card navigation sound (swoosh)
- Selection confirmation (Space press)
- Correct answer (success chime)
- Wrong answer (error buzz)
- Life lost sound
- Phase complete sound
- Victory fanfare
- Defeat sound

## Visual Design Elements

**Card-based UI:**

- Cards with rounded corners, shadows
- Smooth slide/fade animations between cards
- Selected card: larger scale, brighter, centered
- Non-selected cards: smaller, dimmed

**Growing Item Animation:**

- Smooth scale tween from 0.3 to 2.0
- Easing function (quad or cubic ease-out)
- Optional pulsing effect when near timeout

**Phase Indicators:**

- 7 boxes numbered 1-7 at top-left
- Current phase highlighted (filled/colored)
- Completed phases marked (checkmark or green)
- Future phases grayed out

**Lives Display:**

- Player icon with "×3" notation
- Visual feedback when life lost (shake, red flash)
- Icons change color when low (red at ×1)

**Input Field:**

- Cursor blink animation
- "ESPAÇO PARA DIGITAR" prompt
- Highlight on focus
- Character limit based on expected answer length

## Key Implementation Notes

1. **Keyboard-focused navigation**: No mouse required, all controls via keyboard
2. **Card navigation system**: Reusable component for menu screens
3. **Phase progression**: Track through 7 phases, increase difficulty within game
4. **Lives instead of health bar**: Discrete lives (3) rather than continuous health
5. **Mode toggle**: Switch between Math/Language before starting
6. **Explanation feature**: Educational feedback on wrong answers
7. **Version display**: "ver 1.00" shown on menu screens
8. **Age range indicators**: Show target age on difficulty cards
9. **Unified gameplay scene**: Same scene handles both modes with different data
10. **Growing scale animation**: Simple scale-up effect (not movement toward camera)

## Testing Checklist

- Card navigation smooth with arrow keys
- Space confirms selections throughout UI
- Difficulty cards show correct sample questions
- Mode toggle switches between Math/Language
- Phase progression displays correctly (1-7)
- Lives decrease on wrong answers
- Growing animation timing matches difficulty
- Explanation popup shows on mistakes
- Keyboard input works for all answer types
- High score saves and displays correctly
- All sound effects trigger appropriately
- Version number displays on menu screens

### To-dos

- [ ] Initialize Godot 4.x project with folder structure, project settings, and Global.gd autoload
- [ ] Create Global.gd with game state, lives system (3), phase tracking (7), difficulty constants, and save/load
- [ ] Build reusable card navigation component for menu system with keyboard controls
- [ ] Create MainMenu scene with three cards (Tutorial/Jogar/Opções), version display, keyboard navigation
- [ ] Build Tutorial scene explaining game mechanics and controls
- [ ] Create DifficultySelect scene with three difficulty cards showing samples, mode toggle, age ranges
- [ ] Create JSON files (math_questions.json, language_questions.json) with questions for all difficulties
- [ ] Implement GrowingItem.gd with scale animation (0.3 to 2.0), timing based on difficulty
- [ ] Build unified Gameplay scene with phase indicators (7 boxes), lives display (×3), growing question, input field
- [ ] Implement gameplay loop: question loading, answer validation, lives system, phase progression
- [ ] Create ExplanationPopup overlay showing correct answer and explanation on mistakes
- [ ] Build game over scene with victory/defeat states, statistics, high score check
- [ ] Implement complete keyboard control system (arrows, space, shift, enter) across all scenes
- [ ] Integrate all music and sound effects with proper triggers
- [ ] Add card animations, growing effects, phase indicators, lives feedback, input field styling
- [ ] Test complete game flow, keyboard navigation, difficulty balance, save system