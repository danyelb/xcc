# Echipament XCC

Lista de echipament pentru XCC (7–10 noiembrie 2026, Maramureș), cu variante buget / mediu / premium la fiecare poziție.

Pagina e statică și stă pe GitHub Pages: https://danyelb.github.io/xcc/

Bifele, alegerile și notițele se salvează în Supabase după login cu link pe email. Fără login rămân în browser.

## Cum e făcută

- `index.html`: toată aplicația, într-un singur fișier. Folosește `@supabase/supabase-js` de pe jsDelivr.
- `supabase.sql`: tabelul `xcc_state` și regulile de acces (fiecare utilizator își vede doar rândul lui).

Cheia din `index.html` e cheia publică (publishable) a proiectului Supabase. Poate sta în cod pentru că tabelul are Row Level Security. Cheile secrete (`service_role` / `secret`) nu se pun niciodată aici.

## Setări în Supabase

- Authentication → URL Configuration → Site URL: `https://danyelb.github.io/xcc/`
- Redirect URLs: `https://danyelb.github.io/xcc/`
- După primul login, poți opri conturile noi: Authentication → Sign In / Providers → „Allow new users to sign up”.
