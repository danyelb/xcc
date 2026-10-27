# Echipament XCC

Lista de echipament pentru XCC (5–8 noiembrie 2026, Maramureș), cu variante buget / mediu / premium la fiecare poziție.

Pagina e statică și stă pe GitHub Pages: https://danyelb.github.io/xcc/

Bifele, alegerile, notițele și etichetele se salvează în Supabase după login cu link pe email. Fără login rămân în browser.

Fiecare poziție poate avea mai multe etichete (până la 8, de maximum 30 de caractere): alegi din sugestii sau scrii una nouă în panoul care se deschide sub rând. Etichetele apar mici, sub numele poziției, în listă.

## Pe telefon, ca aplicație

- **Android, Chrome:** deschide pagina, apoi butonul „Instalează aplicația pe acest dispozitiv” din sumar sau meniul ⋮ → „Instalează aplicația” / „Adaugă pe ecranul de pornire”.
- **iPhone:** Partajează → „Adaugă pe ecranul principal”.

După prima deschidere cu internet, aplicația merge și fără net. Ce bifezi offline rămâne pe telefon și se trimite în cont când revine netul. Dacă între timp ai modificat lista și de pe alt dispozitiv, varianta de pe telefon o înlocuiește pe cea din cont.

## Cum e făcută

- `index.html`: toată aplicația, într-un singur fișier. Folosește `@supabase/supabase-js` de pe jsDelivr.
- `sw.js`: service worker-ul care ține pagina, biblioteca Supabase și iconițele în telefon, pentru folosire fără internet.
- `manifest.webmanifest` și iconițele `icon-*.png`, `apple-touch-icon.png`, `favicon-32.png`: ca să se poată instala ca aplicație.
- `supabase.sql`: tabelul `xcc_state` și regulile de acces (fiecare utilizator își vede doar rândul lui).

Cheia din `index.html` e cheia publică (publishable) a proiectului Supabase. Poate sta în cod pentru că tabelul are Row Level Security. Cheile secrete (`service_role` / `secret`) nu se pun niciodată aici.

## Setări în Supabase

- Authentication → URL Configuration → Site URL: `https://danyelb.github.io/xcc/`
- Redirect URLs: `https://danyelb.github.io/xcc/`
- După primul login, poți opri conturile noi: Authentication → Sign In / Providers → „Allow new users to sign up”.
