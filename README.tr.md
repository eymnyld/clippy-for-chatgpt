# ChatGPT için Clippy (Codex)

[English README](README.md)

Codex masaüstü uygulaması için hazırlanmış, resmî olmayan ve hayran yapımı animasyonlu Clippy pet paketidir. Codex marketplace plugin’i, prompt ile çalışan kurulum becerisi, macOS/Linux ve Windows kurucuları ve doğrulanmış v2 pet dosyalarını içerir.

> Bu paket **Codex masaüstü peti** kurar. Normal ChatGPT web arayüzüne Clippy eklemez.

![Clippy animasyon temas sayfası](plugins/clippy-for-chatgpt/assets/qa/contact-sheet.png)

## İçerik

- 8×11 Codex v2 atlası (`1536×2288`, saydam WebP)
- 9 standart animasyon durumu
- Saat yönünde 16 bakış yönü
- `spriteVersionNumber: 2` pet manifesti
- SHA-256 doğrulamalı kurucular
- Codex marketplace manifesti ve kurulum becerisi

Haricî connector plugin, API anahtarı veya hesap bağlantısı gerekmez. Bu GitHub reposu doğrudan marketplace/plugin paketidir.

## Codex plugin olarak kurulum

```bash
codex plugin marketplace add eymndev/clippy-for-chatgpt
codex plugin add clippy-for-chatgpt@clippy-for-chatgpt
```

Yeni bir Codex görevi aç ve şu promptu yapıştır:

```text
Use $install-clippy-pet to install the bundled Clippy pet into Codex and verify it. If a different Clippy pet would be overwritten, ask me first.
```

Pet hemen görünmezse Codex masaüstü uygulamasını yeniden başlat.

## Doğrudan kurulum

macOS/Linux:

```bash
git clone https://github.com/eymndev/clippy-for-chatgpt.git
cd clippy-for-chatgpt
./install.sh
```

Windows PowerShell:

```powershell
git clone https://github.com/eymndev/clippy-for-chatgpt.git
Set-Location clippy-for-chatgpt
./install.ps1
```

Kurucu yalnızca `${CODEX_HOME:-$HOME/.codex}/pets/clippy` klasörüne yazar. Farklı bir Clippy paketi `--force` veya `-Force` açıkça verilmeden değiştirilmez.

## Güncelleme

```bash
codex plugin marketplace upgrade clippy-for-chatgpt
codex plugin add clippy-for-chatgpt@clippy-for-chatgpt
```

Yeni bir Codex görevi açıp kurulum promptunu tekrar çalıştır.

## Kaldırma

```bash
./uninstall.sh --yes
```

Windows:

```powershell
./uninstall.ps1 -Yes
```

## Doğrulama

```bash
python3 scripts/validate_repo.py
```

Kod ve özgün dokümantasyon MIT lisanslıdır. Clippy karakteri, adı, referans görselleri ve türetilmiş sprite çizimi MIT kapsamına dahil değildir. Proje Microsoft, OpenAI veya ChatGPT ile bağlantılı ya da onlar tarafından onaylanmış değildir. Ayrıntılar: [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
