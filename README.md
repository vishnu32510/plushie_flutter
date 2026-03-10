<br/>
<p align="center">
  <a href="https://github.com/vishnu32510/plushie_flutter">
    <img src="assets/images/appIcon.png" alt="Logo" width="80" height="80" style="border-radius: 14px;">
  </a>
  <h1 align="center">Plushie Yourself</h1>
</p>

A Flutter app that transforms your photos into adorable plushie-style images using OpenAI's `gpt-image-1` API.

## Features

* **Photo to Plushie** — Pick any photo and get a plushie-style version in seconds
* **Before / After Comparison** — Side-by-side view of original and transformed image
* **Clean Warm UI** — Beige/amber palette designed around the plushie aesthetic
* **BLoC Architecture** — Clean separation of UI and business logic

## Built With

* Flutter SDK + BLoC
* OpenAI `gpt-image-1` via `/v1/images/edits`

## Setup & Run

1. **Clone**
   ```bash
   git clone https://github.com/vishnu32510/plushie_flutter.git
   cd plushie_flutter
   ```

2. **Dependencies**
   ```bash
   flutter pub get
   ```

3. **API Key**
   - Copy `.env.example` to `.env`
   - Add your OpenAI API key: `OPENAI_API_KEY=your_key_here`

4. **Run**
   ```bash
   flutter run
   ```

## Authors

* **Vishnu Priyan** - *Mobile Application Developer* - [vishnu32510](https://github.com/vishnu32510)
