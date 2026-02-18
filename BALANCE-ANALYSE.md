# Balance-Analyse: Weltraumschlacht

> Stand: 2026-02-18 -- Komplette Spielmechanik-Analyse unter Berucksichtigung von FUT-19 (Schildlinien) und FUT-20 (Raumstationen). Updates: Graduierte Stations-Sichtbarkeit (SS-09a), Stationszerstorungs-Verluste (SS-13a/38/39), Kampfberichte fur alle Station-Kampfe, Rebellenplaneten-Produktion (RB-12–14), Desertions-Mechanik + kein Defender-Bonus bei Rebellion (RB-15–16).

---

## 1. Aktuelle Mechaniken -- Parameterlandschaft

### 1.1 Produktionssystem

| Modus | Effekt pro Runde | Effektive Rate | Opportunity Cost |
|-------|-----------------|----------------|------------------|
| Fighter | +`prod_rate` Fighter | 1.0x | Keine |
| Bomber | +`prod_rate` Bomber alle 2 Runden | 0.5x (Schiffe/Runde) | 50% Produktionsverlust vs Fighter |
| Upgrade | +1 prod_rate nach `prod_rate` Runden | 0.0x (wahrend Upgrade) | Voller Produktionsausfall |
| Battery Build | +1 Batterie nach `battery_count+1` Runden | 0.0x (wahrend Bau) | Voller Produktionsausfall |

**Analyse:** Fighter-Produktion ist der effizienteste Modus fur sofortige Kampfkraft. Bomber haben durch die 1.5x Angriffskraft eine effektive Kampfkraft von 0.75x pro Runde verglichen mit Fightern (0.5 Produktionsrate x 1.5 Angriff). Allerdings sind Bomber durch ihre niedrigere Defense (0.67x) anfalliger. Die Rechtfertigung fur Bomber liegt im Produktionsschaden und der hoheren Effektivitat gegen Batterien (50% Resistenz gegen Batterie-Feuer).

### 1.2 Upgrade-ROI-Analyse

Ein Upgrade von Rate N auf N+1 kostet N Runden ohne Produktion.

| Start-Rate | Upgrade-Kosten (Runden) | Entgangene Fighter | Amortisation (Runden bis +1/Runde sich lohnt) | Gesamt bis Gewinn |
|------------|------------------------|--------------------|-------------------------------------------------|-------------------|
| 1 -> 2 | 1 | 1 | 1 | **2 Runden** |
| 2 -> 3 | 2 | 4 | 4 | **6 Runden** |
| 3 -> 4 | 3 | 9 | 9 | **12 Runden** |
| 4 -> 5 | 4 | 16 | 16 | **20 Runden** |
| 5 -> 6 | 5 | 25 | 25 | **30 Runden** |
| 6 -> 7 | 6 | 36 | 36 | **42 Runden** |
| 7 -> 8 | 7 | 49 | 49 | **56 Runden** |

**Fazit:** Upgrades bis Rate 4-5 sind in typischen Spiellangen (30-60 Runden) rentabel. Upgrades auf 6+ lohnen sich nur in sehr langen Spielen oder auf sicheren Hinterland-Systemen. Die Economy-AI-Taktik (Upgrade-Fokus bis avg >= 5) ist gut kalibriert.

### 1.3 Batterie-Investitionskosten

| Level | Bauzeit (Runden) | Kumulativ (Runden) | Entgangene Fighter (Rate 3) | Batterie-Kills pro Angriff |
|-------|-----------------|--------------------|-----------------------------|---------------------------|
| 0 -> 1 | 1 | 1 | 3 | 3 F oder 1.5 B |
| 1 -> 2 | 2 | 3 | 9 | 6 F oder 3 B |
| 2 -> 3 | 3 | 6 | 18 | 9 F oder 4.5 B |
| 3 -> 4 | 4 | 10 | 30 | 12 F oder 6 B |
| 4 -> 5 | 5 | 15 | 45 | 15 F oder 7.5 B |

Formel: `Batterie-Kills = battery_count x BATTERY_DAMAGE_PER_ROUND (3.0)`, gegen Bomber nur 50% effektiv.

**Analyse:** 5 Batterien kosten kumulativ 15 Runden Bauzeit (bei Rate 3 = 45 entgangene Fighter). Dafur zerstoren sie pro Angriffswelle 15 Fighter oder 7-8 Bomber. Bei MAX_FLEET_SIZE = 40 vernichten 5 Batterien 37.5% einer reinen Fighter-Welle. Das macht Batterien extrem stark gegen einzelne Wellen, aber Angreifer konnen mehrere Wellen nacheinander schicken (jede Welle trifft auf die gleichen Batterien).

**Batterie-ROI:** 5 Batterien "verdienen" sich bei jedem Angriff 15 Fighter-Aquivalente zuruck. Ab dem 3. abgewehrten Angriff (45 vernichtete Fighter) ist die Investition amortisiert.

**Schildlinien-Batterieunterstützung:** Verbundene Nachbarsterne feuern mit: `Nachbar-Batterien × Schilddichte × 0.5`. Bei 2 Nachbarn mit je 5 Batterien und Dichte 1.0 (120px): +5 effektive Batterien → 30 Kills/Welle statt 15. Bei Dichte 0.5 (185px): +2.5 → 22.5 Kills/Welle. Starke defensive Synergie, aber abhangig von kompakter Sternverteilung.

### 1.4 Kampfsystem

#### Erwartungswerte

| Szenario | Angreifer | Verteidiger | Erwarteter Sieger | Begrundung |
|----------|-----------|-------------|-------------------|------------|
| Gleichstarke Krafte | 20 F | 20 F | Verteidiger | DEFENDER_BONUS 1.5x |
| Numerische Uberlegenheit | 30 F | 20 F | Ausgeglichen | 30 x 1.0 vs 20 x 1.5 = 30 vs 30 |
| Kritische Uberlegenheit | 40 F | 20 F | Angreifer klar | 40 x 1.0 vs 20 x 1.5 = 40 vs 30 |
| Bomber-Angriff | 20F + 10B | 20F | Angreifer | Angriff: 20+15=35 vs 20x1.5=30 |
| Gegen Batterien (3) | 40 F | 10 F + 3 Bat | Angreifer knapp | 31 F nach Bat. vs 10 x 1.5 = 15 |
| Gegen max Batterien (5) | 40 F | 20 F + 5 Bat | Verteidiger | 25 F nach Bat. vs 20 x 1.5 = 30 |

#### Morale-Analyse

| Reisezeit (Runden) | Fighter-Moral | Effektive Angriffskraft (40 F) | Verlust vs volle Moral |
|---------------------|--------------|-------------------------------|------------------------|
| 1-2 | 100% | 40.0 | 0% |
| 3 | 80% | 32.0 | -20% |
| 4 | 60% | 24.0 | -40% |
| 5+ | 50% (Min) | 20.0 | -50% |

**Analyse:** Moral ist ein massiver Faktor. Ein Angriff uber 5+ Runden hat nur die halbe Fighter-Angriffskraft. Das begrenzt effektive Angriffsreichweite auf ~2-3 Systemdistanzen (300-750px bei Fightern). Bomber sind unaffektiert -- ihre 1.5x Angriffskraft bleibt uber jede Distanz erhalten, was Bomber fur Fernangriffe wertvoll macht.

#### Wellen-Splitting-Effekt

MAX_FLEET_SIZE = 40 bewirkt, dass grosse Armeen in 40er-Wellen aufgeteilt werden. Jede Welle trifft einzeln auf Batterien.

| Armee-Grosse | Wellen | Batterie-Verluste (5 Bat) | Uberlebende | Effizienz |
|-------------|--------|--------------------------|-------------|-----------|
| 40 | 1 | 15 | 25 | 62.5% |
| 80 | 2 | 30 | 50 | 62.5% |
| 120 | 3 | 45 | 75 | 62.5% |

Batterien skalieren linear -- sie werden nie ineffizienter. Das Wellen-Splitting verhindert Deathball-Strategien nicht komplett, erhoht aber die Batterie-Wirksamkeit drastisch im Vergleich zu einem System ohne Wellenbegrenzung.

### 1.5 Rebellions-Mechanik

**Trigger:** Power Score eines Spielers > Durchschnitt × 1.3 (gewichtete Summe: Systemanzahl × 4.0, Kampfkraft × 0.1, Produktion × 0.5).

**Beispiel (4 Spieler, 35 Systeme total):**
- Chance pro ungeschutztem System = (power_ratio - 1.3) × 0.3
- Bei power_ratio 1.5: Chance = (1.5 - 1.3) × 0.3 = 6% pro System
- Bei power_ratio 2.0: Chance = (2.0 - 1.3) × 0.3 = 21% pro System

**Rebellionsstärke:** `prod_rate × 3` neutrale Fighter + desertierte Garrison-Fighter, ohne Defender-Bonus.

**Desertion (RB-15):** `floor(garrison_f × clamp((power_ratio - 1.3) × 0.5, 0, 0.5))` Fighter laufen über (Bomber bleiben loyal). Bei power_ratio 1.5: 10% desertieren. Bei power_ratio 2.0: 35%. Cap: 50%.

**Kein Defender-Bonus (RB-16):** Rebellen sind Einheimische — kein 1.5×-Heimvorteil für die Garnison.

| System-Rate | Rebel-Fighter base | + Deserteure (10%) | Gesamt vs. 18F Garnison |
|-------------|-------------------|--------------------|------------------------|
| 1 | 3 | +2 | 5 vs 18 |
| 3 | 9 | +2 | 11 vs 18 |
| 5 | 15 | +2 | 17 vs 18 |
| 8 | 24 | +2 | 26 vs 18 |

**Neue Dynamik: Rebellenplaneten produzieren Fighter (2026-02-18)**

Nach einer erfolgreichen Rebellion (is_rebel = true) produziert das System jede Runde Fighter:

| Runde nach Rebellion | Produktion (bei Rate 5) | rebel_decay | Effektive Rate |
|---------------------|------------------------|-------------|----------------|
| 1 | 5 F/Runde | 0 | 5 |
| 2 | 3 F/Runde | 2 | 3 |
| 3 | 1 F/Runde | 4 | 1 (Untergrenze) |
| 4+ | 1 F/Runde | 6+ | 1 (gedeckelt) |

**Strategische Implikation:** Ein Rebellenplanet ist anfangs gefährlicher als ein normaler Neutralplanet, beruhigt sich aber von selbst. Je schneller der dominante Spieler zurückerobert, desto weniger Fighter haben sich angesammelt. Bei Rückeroberung: -2 Produktionspunkte (statt -1) als dauerhafter Kriegsschaden.

**Fazit:** Rebellion ist ein effektiver Snowball-Bremser. Durch Desertion + keinen Defender-Bonus werden auch gut besetzte Systeme angreifbar, wenn der Spieler zu stark dominiert. Bomber-Garnisonen bieten natürliche Stabilität gegen Rebellion. Dominante Spieler müssen schnell reagieren und zahlen dauerhaft mehr Produktionskraft für Rückerobern.

**Batterien als Rebellionsschutz -- Kosten-Nutzen:**
- 1 Batterie: 1 Runde Bau, -20% Rebellionschance
- 2 Batterien: 3 Runden kumulativ, -40% Rebellionschance
- 3 Batterien: 6 Runden kumulativ, -60% Rebellionschance
- 5 Batterien: 15 Runden kumulativ, -100% (immun)

---

## 2. AI-Taktik-Analyse

### 2.1 Taktik-Profile

| Taktik | Starke | Schwache | Optimale Phase |
|--------|--------|----------|----------------|
| **Rush** | Schnelle Expansion, Zahlenuberlegenheit | Keine Upgrades, keine Batterien, keine Bomber | Fruhes Spiel |
| **Fortress** | Starke Verteidigung, Upgrades im Hinterland | Langsame Expansion, passiv gegen Feinde | Mittleres/Spates Spiel |
| **Economy** | Hohe Produktion langfristig | Verletzlich in fruhen Phasen | Spates Spiel |
| **Bomber** | Produktionsschaden, hohe Angriffskraft | Langsame Produktion, langsame Flotten | Mittleres Spiel |
| **Balanced** | Flexibel, moderater Batterie-Bau | Kein klarer Vorteil, "Master of None" | Alle Phasen |

### 2.2 Taktik-Matchups (theoretisch)

| Angreifer vs Verteidiger | Rush | Fortress | Economy | Bomber | Balanced |
|--------------------------|------|----------|---------|--------|----------|
| **Rush** | 50/50 | Schlecht | Gut | Neutral | Neutral |
| **Fortress** | Gut | Stalemate | Neutral | Schlecht | Neutral |
| **Economy** | Schlecht | Neutral | 50/50 | Neutral | Neutral |
| **Bomber** | Neutral | Gut | Neutral | 50/50 | Neutral |
| **Balanced** | Neutral | Neutral | Neutral | Neutral | 50/50 |

**Schlusselmatchups:**
- **Rush vs Economy:** Rush gewinnt fruh durch numerische Uberlegenheit bevor Economy-Upgrades greifen
- **Fortress vs Bomber:** Bomber haben 50% Batterie-Resistenz und verursachen Produktionsschaden -- idealer Gegenpart zur Festungsstrategie
- **Rush vs Fortress:** Fortress hat Batterien + Verteidigungsbonus, Rush kann nicht effizient angreifen

### 2.3 AI-Verhaltensanalyse

**Schwachstellen im aktuellen AI-Code:**

1. **Fehlende Koordination:** Jedes System sendet unabhangig Flotten. Keine koordinierten Doppelangriffe auf ein Ziel.
2. **Keine Flottensammlung:** AI sendet immer sofort, statt auf einem System zu sammeln und als grossere Kraft zuzuschlagen.
3. **Statische Garnisonstarke:** `min_garrison = 4-10` ist fix, unabhangig von Bedrohungslage.
4. **Keine Bomber-Nutzung ausser Bomber-Taktik:** Rush, Fortress, Economy ignorieren Bomber komplett.
5. **Kein Risikomanagement:** AI beachtet keine Rebellion-Gefahr, baut keine praventiven Batterien.

---

## 3. Balance-Bewertung: Aktueller Zustand

### 3.1 Symmetrie & Fairness

| Aspekt | Bewertung | Kommentar |
|--------|-----------|-----------|
| Startpositionen | Gut | Greedy-Maximum-Distanz + Kompensation durch 1-Hop + 2-Hop Nachbar-abhängige Startfighter |
| Produktionsraten | Fair | Zufall (1-5), aber alle Spieler starten mit Rate 3 |
| Fog of War | Gut | Gleiche Sichtweite, Memory-System verhindert totale Blindheit |
| Kampfsystem | Ausbalanciert | DEFENDER_BONUS 1.5x bevorzugt Verteidigung angemessen |

### 3.2 Strategische Spannung

| Spannung | Status | Kommentar |
|----------|--------|-----------|
| Offense vs Defense | **Gut** | Batterien + Verteidigungsbonus vs Bomber + numerische Uberlegenheit |
| Expansion vs Konsolidierung | **Gut** | Rebellion bremst Uber-Expansion, Upgrades belohnen Konsolidierung |
| Fighter vs Bomber | **Akzeptabel** | Fighter effizienter in Produktion, Bomber besser gegen Batterien und fur Fernangriffe |
| Kurz- vs Langstrecke | **Gut** | Moral-Malus bestraft Fernangriffe, Bomber als Alternative |

### 3.3 Bekannte Balance-Probleme

1. **Deathball immer noch stark:** Trotz Wellen-Splitting konnen 120+ Fighter jedes System uberrollen. Batterien verzogern, stoppen aber nicht.
2. **Turtling schwer zu brechen:** 5 Batterien + hohe Garnison = fast uneinnehmbar. Bomber sind der einzige Counter, aber schwierig zu produzieren und langsam.
3. **Keine territoriale Kontrolle:** Flotten konnen frei uberall hinreisen. Kein Konzept von "Frontlinien" oder "Hinterland" ausser durch Sichtweite.
4. **Late-Game Stalemate:** Wenn zwei Spieler gleich stark sind und Batterien haben, kommt es oft zum Stillstand.

---

## 4. Impact-Analyse: FUT-19 (Schildlinien)

### 4.1 Neue strategische Dimension

Schildlinien transformieren das Spiel fundamental von "Punkt-Verteidigung" zu "Territorial-Verteidigung":

```
VORHER:                          NACHHER:
Systeme sind isolierte Punkte    Systeme bilden vernetzte Verteidigungslinien

[A]  [B]  [C]                   [A]===SCHILD===[B]===SCHILD===[C]
 |    |    |                     |    Gebiet    |    Gebiet    |
[D]  [E]  [F]                   [D]===SCHILD===[E]===SCHILD===[F]
                                      Ring = +25% innere, +12% Ring
```

### 4.2 Shield-Density-Analyse

`shield_density = 1.0 - (distance - 120) / (250 - 120)`

| Distanz (px) | Density | Effektive Starke | Bewertung |
|-------------|---------|------------------|-----------|
| 120 (min) | 1.00 | Maximum | Undurchdringlich bei hohen Batterien |
| 150 | 0.77 | Hoch | Starke Schildlinie |
| 180 | 0.54 | Mittel | Nutzbare Verteidigung |
| 200 | 0.38 | Schwach | Geringe Attrition |
| 220 | 0.23 | Sehr schwach | Kaum Wirkung |
| 250 (max) | 0.00 | Keine | Wirkungslos |

**Fazit:** Nur Systempaare im Bereich 120-180px bilden effektive Schildlinien. Das bevorzugt naturlich kompakte Reiche mit eng beieinander liegenden Systemen.

### 4.3 Blockade-Analyse

Blockade tritt ein wenn `min(bat_a, bat_b) x density >= 2.5` (Fighter) bzw. `>= 5.0` (Bomber).

| Batterien (min) | Density fur Fighter-Blockade | Distanz (px) | Density fur Bomber-Blockade | Distanz (px) |
|-----------------|-----------------------------|--------------|-----------------------------|--------------|
| 2 | 1.25 (unmoglich) | -- | 2.5 (unmoglich) | -- |
| 3 | 0.83 -> ~142px | 142 | 1.67 (unmoglich) | -- |
| 4 | 0.63 -> ~168px | 168 | 1.25 (unmoglich) | -- |
| 5 | 0.50 -> ~185px | 185 | 1.00 -> 120px | 120 |

**Kritische Erkenntnis:** Fighter-Blockade ist ab 3 Batterien/System bei kurzen Distanzen erreichbar. Bomber konnen nur bei maximalen Batterien und minimaler Distanz blockiert werden. **Bomber sind der primare Counter gegen Schildlinien.**

### 4.4 Attrition-Analyse

Attrition: `(bat_a + bat_b) x density x SHIELD_DAMAGE_FACTOR (0.04) x ship_count`

| Batterien (Summe) | Density | Verluste (40 Fighter) | Verluste (40 Bomber, 50% Resistenz) |
|-------------------|---------|----------------------|-------------------------------------|
| 4 (2+2) | 1.0 | 6.4 (16%) | 3.2 (8%) |
| 6 (3+3) | 0.77 | 7.4 (18.5%) | 3.7 (9.3%) |
| 8 (4+4) | 0.54 | 6.9 (17.3%) | 3.5 (8.6%) |
| 10 (5+5) | 1.0 | 16.0 (40%) | 8.0 (20%) |
| 10 (5+5) | 0.50 | 8.0 (20%) | 4.0 (10%) |

**Analyse:** Schildlinien verursachen 10-40% Verluste pro Durchquerung, abhangig von Batterien und Density. Bei maximalen Batterien und minimaler Distanz verliert eine Fighter-Flotte 40% ihrer Starke -- und trifft dann noch auf die lokalen Batterien (weitere 15 Kills) und die Garnison (mit 1.5x Bonus). **Defense-in-Depth wird extrem machtig.**

### 4.5 Ring-Bonus-Analyse

Geschlossene Ringe gewahren: innere Sterne +25%, Ring-Sterne +12% Produktionsbonus.

**Beispiel -- Ring aus 4 Systemen (Rate 5), 1 innerer Stern (Rate 4):**

| System | Basis-Rate | Bonus | Effektive Rate | Zusatzliche Fighter/Runde |
|--------|-----------|-------|----------------|--------------------------|
| Ring A | 5 | +12% | 5.6 -> 5 (+0.6 Uberlauf) | ~0.6 |
| Ring B | 5 | +12% | 5.6 | ~0.6 |
| Ring C | 5 | +12% | 5.6 | ~0.6 |
| Ring D | 5 | +12% | 5.6 | ~0.6 |
| Inner X | 4 | +25% | 5.0 | +1.0 |

Da Produktionsraten ganzzahlig sind, muss der Bonus entweder abgerundet oder als Fliesskomma-Produktion implementiert werden. Bei Rundung auf Integer ware der Ring-Bonus erst bei hoheren Raten spurbar (Rate 8 + 25% = 10, effektiv +2).

**Empfehlung:** Bonus als zusatzliche Fighter-Produktion (fraktional akkumuliert, ahnlich Bomber-Batch-System) implementieren, nicht als permanente Ratenerhohung.

### 4.6 Investitionskosten vs Ertrag

**Kosten einer Schildlinie (2 Systeme, je 2 Batterien, Aktivierung):**
- 2x 3 Runden Batterie-Bau = 6 Runden Produktionsausfall pro System
- 2 Runden Aktivierung (beide blockiert) = 2 Runden Produktionsausfall pro System
- Gesamt: 8 Runden Produktionsausfall pro System, 16 Runden-Aquivalent total
- Bei Rate 3: 48 entgangene Fighter

**Ertrag:**
- Jede feindliche 40er-Welle verliert ~6-16 Fighter beim Durchqueren
- Blockade ab 3 Batterien/System bei kurzer Distanz
- Komplett-Blockade fur Fighter bei 5+5 Batterien

**Amortisation:**
- Bei 6 Fighter-Verlust pro Welle: ~8 abgewehrte Wellen bis Amortisation (unwahrscheinlich)
- Der wahre Wert liegt in der **Abschreckungswirkung** und **Routenkontrolle**, nicht in den absoluten Kills

---

## 5. Impact-Analyse: FUT-20 (Raumstationen)

### 5.1 Kosten-Analyse

| Komponente | Kosten (FA) | Baurunden | Minimum Lieferzeit |
|------------|------------|-----------|---------------------|
| Station | 24 FA | 3 | 5-10 Runden (Produktion + Reise) |
| Batterie 1 | 4 FA | 1 | 2-3 Runden |
| Batterie 2 | 8 FA | 2 | 3-5 Runden |
| **Voll ausgebaut** | **36 FA** | **6** | **10-18 Runden** |

**Vergleich:** 36 Fighter-Aquivalente = 36 Fighter oder 18 Bomber. Ein Rate-5-System braucht ~7 Runden um 36 Fighter zu produzieren. Die Station hat keinen direkten Kampfwert (keine Produktion), ihre Starke liegt in der **Positionierung**.

### 5.2 Strategischer Wert

**Offensiver Wert:**
- Station hinter feindlicher Schildlinie platziert -> Flotten konnen feindliche Systeme ohne Schildkreuzung angreifen
- Staging-Punkt: Flotten sammeln sich auf Station -> Angriff mit voller Moral (kurze Distanz)
- Eliminiert Fighter-Moral-Malus fur Fernangriffe

**Defensiver Wert:**
- Schliesst Lucken im Schildnetzwerk
- Passiver Scan uber volle Sichtweite (250px, deckt Lucken zwischen Sternen ab)

**Zerstorungskosten (SS-13a):**
Angreifende Schiffe, die eine Station erfolgreich zerstoren, gehen ebenfalls verloren (kein Ruckkehr-Ziel). Das macht Stationsangriffe grundsatzlich teurer als Systemangriffe:
- Angreifer verliert **alle uberlebenden Schiffe** zusatzlich zu den Kampfverlusten
- Ein 40-Fighter-Angriff auf eine garnisonslose Station kostet 40 Fighter (selbst bei null Gegenwehr)
- Gegen Batterien: Batterie-Kills + alle Uberlebenden verloren = 100% Verlustrate
- **Balance-Implikation:** Stationen als "Honeypot" -- Angreifer muss abwagen, ob Zerstorung die Totalverluste wert ist

### 5.3 Sichtbarkeits-Dynamik (Graduierte Sichtbarkeit, SS-09a)

Stationen sind nicht binär sichtbar/unsichtbar, sondern haben eine **Waffen-Signatur**, die proportional zur Garnisonsgrosse wachst:

**Waffen-Signatur:** `signature_range = garrison_size × STATION_SIGNATURE_PER_SHIP (10px)`
**Bau-Signatur:** `STATION_BUILD_SIGNATURE = 30px` (ab build_progress >= 1)

| Garnison | Signatur-Reichweite | Taktische Bedeutung |
|----------|--------------------|--------------------|
| 0 Schiffe | 0px | Unsichtbar (nur passiver Scan entdeckt) |
| 1-5 Schiffe | 10-50px | Praktisch unsichtbar |
| 10 Schiffe | 100px | Von nahen Sternen/Stationen entdeckbar |
| 20 Schiffe | 200px | Von den meisten Nachbarsternen entdeckbar |
| 30+ Schiffe | 300px+ | Grossflachig sichtbar, kaum zu verbergen |
| Im Bau | 30px | Minimale Bau-Signatur, schwer entdeckbar |

| Scan-Methode | Reichweite | Zuverlassigkeit | Kosten |
|--------------|-----------|-----------------|--------|
| Passiver Scan (Sterne) | STATION_PASSIVE_SCAN_RANGE (200px) | 100% | Kostenlos |
| Passiver Scan (Stationen, operativ) | MAX_SYSTEM_DISTANCE (250px) | 100% | 1 Station-Slot |
| Passiver Scan (Stationen, im Bau ≥2/3) | 125px (50% von 250px) | 100% | 1 Station-Slot |
| Waffen-Signatur | garrison × 10px | Proportional zur Starke | Tarnung verloren |
| Bau-Signatur | 30px | Nur wahrend Bau | Gering |
| Flotten-Scan (25+ Schiffe) | 60px | Situativ | Flotte muss vorbei |
| Flotten-Scan (6-24 Schiffe) | 3-57px | Gering | Flotte muss nah vorbei |

**Analyse:** Die graduierte Sichtbarkeit schafft ein fundamentales Dilemma: **Starke vs Tarnung**. Eine leere Station ist unsichtbar, aber nutzlos im Kampf. Eine voll garnisierte Station (30+ Schiffe) ist kampfstark, aber weit sichtbar. Das erzwingt taktische Entscheidungen:

- **Stealth-Staging:** Station leer halten, Fighter erst kurz vor Angriff schicken (Just-in-Time). Risiko: Fighter unterwegs sichtbar, Ankunftszeit kostet Uberraschung.
- **Forward Operating Base:** Station permanent garnisieren. Vorteil: sofortige Einsatzbereitschaft. Nachteil: Signatur verrat Position.
- **Bau-Phase:** STATION_BUILD_SIGNATURE = 30px ist sehr gering -- Station im Bau ist praktisch nur durch passiven Scan (Stern/Station in <30px Nahe) oder Zufall entdeckbar.

**Balance-Implikation:** Die Signatur-Mechanik verhindert "unsichtbare Festungen" (eine Station mit 40 Garnison hat 400px Signatur -- praktisch kartenweit sichtbar) und belohnt taktische Zuruckhaltung bei der Garnisonierung.

### 5.4 Kettenbau-Reichweite

| Stationen | Max Reichweite | Kostet Slots | Risiko |
|-----------|---------------|-------------|--------|
| 1 | 250px | 1/3 | Gering |
| 2 (Kette) | 500px | 2/3 | Mittel |
| 3 (Kette) | 750px | 3/3 | Hoch (alle Slots) |

Bei 750px maximaler Kettenreichweite kann ein Spieler fast die gesamte Karte erreichen. Allerdings bindet das alle 3 Station-Slots und erfordert 72 FA (3 x 24) an Baumaterial -- eine massive Investition.

---

## 6. Interaktionsmatrix: Alle Mechaniken

### 6.1 Synergien und Konflikte

```
                     Fighter  Bomber  Batterie  Upgrade  Schild  Station  Rebellion
Fighter              --       Neutral  Counter   Neutral  Counter  Neutral  Garnison
Bomber               Neutral  --       50%Res    Neutral  50%Res   Baumat.  Irrelevant
Batterie             Counter  Schwach  --        Konflikt Voraus.  Voraus.  Reduktion
Upgrade              Neutral  Neutral  Konflikt  --       Neutral  Neutral  Irrelevant
Schildlinie          Counter  Schwach  Synergie  Bonus    --       Synergie Bricht
Raumstation          Neutral  Baumat.  Moglich   Nein     Synergie --       Immun
Rebellion            Verlust  Verlust  Schutz    Neutral  Bricht   Immun    --
```

### 6.2 Kritische Interaktionen

| Interaktion | Effekt | Balance-Implikation |
|-------------|--------|---------------------|
| Batterien + Schildlinien + Wellen-Split | Dreifach-Verteidigung: Schildverluste -> Batterie-Kills -> Kampf mit Bonus | **Potenziell zu stark** |
| Bomber + Schildlinien | 50% Resistenz -> Bomber als Schild-Durchbrecher | **Gut balanciert** -- gibt Bomber klare Rolle |
| Rebellion + Schildlinien | Rebellion kann Schildlinie brechen (Batterien fallen unter 2) | **Gut** -- verhindert unverwundbare Festungen |
| Rebellion + Produktion | Rebellenplanet produziert Fighter (abklingend) -> Zeitdruck + dauerhafter -2 Prod.-Malus bei Rückeroberung | **Gut** -- verschärft Anti-Snowball ohne Überhang |
| Stationen + Schildlinien | Station hinter Schild -> Umgehung der Verteidigung | **Kerndesign** -- Counter gegen Turtle |
| Moral + Schildlinien | Geschwachte Fighter treffen auf Schild -> doppelte Bestrafung | **Potenziell zu hart** fur Fernangriffe |
| Station + Moral | Station als Staging-Punkt -> volle Moral fur kurze Angriffe | **Gut** -- Counter gegen Moral-Malus |
| Station + Zerstorungsverluste | Angreifer verliert alle Uberlebenden bei Stationszerstorung | **Gut** -- Stationen als "teures Ziel" |
| Signatur + Garnison | Grosse Garnison = hohe Sichtbarkeit, Tarnung vs Kampfkraft | **Gut** -- erzwingt taktische Abwagung |

---

## 7. Szenarioanalyse: Spielphasen mit FUT-19/20

### 7.1 Fruhes Spiel (Runde 1-10)

**Aktuelle Mechanik:** Alle expandieren aggressiv zu neutralen Systemen. Startfighter-Kompensation sorgt fur faire Ausgangslage.

**Mit FUT-19/20:** Unverandert. Schildlinien erfordern min. 2 Batterien (fruuhestens ab Runde 3 verfugbar), Stationen kosten 24 FA (zu teuer in dieser Phase). Fruhes Spiel bleibt rush-orientiert.

### 7.2 Mittleres Spiel (Runde 10-30)

**Aktuelle Mechanik:** Grenzen stabilisieren sich, erste Kampfe um neutrale/feindliche Systeme, Produktions-Upgrades beginnen.

**Mit FUT-19/20:**
- **Fortress/Balanced:** Beginnen Batterien zu bauen (Runde 10-15), konnen erste Schildlinien aktivieren (Runde 15-20)
- **Economy:** Upgrades-first, spater Batterien fur Rebellionsschutz
- **Rush:** Hat keine Batterien, kann aber durch schiere Zahlen Schildlinien uberwaltigen
- **Bomber:** Beginnt Bomber-Produktion, idealer Zeitpunkt um Schildlinien zu durchbrechen

**Neues strategisches Element:** Spieler mussen entscheiden: **"Baue ich Schildlinien oder nutze ich die Ressourcen fur Angriff?"** -- signifikante Opportunity-Cost (16 Runden-Aquivalent pro Linie).

### 7.3 Spates Spiel (Runde 30+)

**Aktuelle Mechanik:** Stalemates wenn Spieler gleich stark, Snowball wenn einer dominiert (gebremst durch Rebellion).

**Mit FUT-19/20:**
- **Schildlinien** definieren klare Frontlinien und Territorien
- **Stalemate-Breaker:** Stationen ermoglichen Flankenangriffe hinter Schildlinien
- **Ringe** gewahren Produktionsbonus -> belohnen territoriale Kontrolle
- **Rebellionen** konnen Schildlinien brechen -> unerwartete Offnungen

**Neues Late-Game-Pattern:**
1. Spieler A baut Schildwall
2. Spieler B baut Station hinter dem Wall (Bau-Signatur 30px, fast unsichtbar)
3. Spieler B schickt Garnison zur Station -- ab ~20 Schiffen Signatur 200px, Entdeckungsgefahr steigt
4. Spieler A muss Scan-Lucken schliessen oder Garnisonen im Hinterland halten
5. Spieler B greift von Station aus an -- Stationszerstorung kostet Spieler A **alle** angreifenden Schiffe
6. Schildlinie wird durch Eroberung eines Endpunkts gebrochen
7. Spieler A muss neue Verteidigung aufbauen

**Neues Dilemma fur Stations-Angriffe:** Die Zerstorung einer feindlichen Station kostet alle uberlebenden Angreifer. Spieler muss abwagen: Station zerstoren (teuer, aber sicher) oder Station ignorieren und direkt Systeme angreifen (riskant, feindliche Station bleibt aktiv).

---

## 8. Balance-Risiken und Empfehlungen

### 8.1 Risiko: Turtle-Meta

**Problem:** Schildlinien + Batterien + Verteidigungsbonus konnen Verteidigung uberproportional begunstigen. Ein Spieler mit einem kompakten Reich, 5 Batterien auf allen Systemen und Schildlinien konnte praktisch unbesiegbar werden.

**Gegengewichte im aktuellen Design:**
- Bomber: 50% Schild-Resistenz, Produktionsschaden
- Rebellion: Bricht Schildlinien, zwingt zu Garnisonierung
- Stationen: Umgehen Schildlinien komplett
- Max 2 Strukturen: Begrenzt Schildnetzwerk-Ausdehnung
- Aktivierungskosten: 2 Runden x 2 Systeme = signifikanter Produktionsverlust

**Bewertung:** Die Counter sind vorhanden aber **nicht stark genug quantifiziert**. Empfehlung:

| Empfehlung | Prioritat | Begrundung |
|------------|----------|------------|
| SHIELD_DAMAGE_FACTOR auf 0.03 statt 0.04 testen | Mittel | 4% konnte bei 10 Batterien (40%) zu viel sein |
| Bomber-Resistenz auf 40% statt 50% erhohen | Niedrig | Nur wenn Bomber zu schwach gegen Schilde |
| Max Strukturen auf 3 erhohen | Niedrig | Nur wenn 2 zu restriktiv fur grosse Reiche |

### 8.2 Risiko: Bomber-Pflicht

**Problem:** Wenn Schildlinien zu stark sind, werden Bomber zur Pflicht fur jeden Angriff. Das reduziert strategische Vielfalt.

**Empfehlung:** Schildlinien sollten **verzogernd** wirken, nicht **verhindernd**. Die Blockade-Schwellwerte sind hier entscheidend:
- Fighter-Blockade bei min x density >= 2.5 ist erreichbar ab 3 Batterien / 142px
- Das konnte zu haufig vorkommen

**Alternative:** Blockade-Schwellwert auf 3.0 erhohen -> nur bei 4+ Batterien und kurzer Distanz.

### 8.3 Risiko: Stalemate-Vertiefung statt -Losung

**Problem:** Schildlinien konnten Stalemates verstarken statt sie aufzulosen, wenn beide Seiten Schildwalle bauen.

**Gegenargument:** Stationen (FUT-20) sind explizit als Stalemate-Breaker designed. Ein Spieler, der hinter dem feindlichen Schild eine Station errichtet, erzwingt eine Reaktion.

**Empfehlung:** FUT-19 und FUT-20 **mussen zusammen** implementiert werden. FUT-19 allein wurde das Turtle-Meta massiv verstarken.

### 8.4 Risiko: AI-Uberforderung

**Problem:** AI muss Schildlinien-Aktivierung, Pfad-Vermeidung, Stations-Bau, Scan-Management und Schildlinien-Durchbruch verstehen. Das ist komplex.

**Empfehlung:** Schrittweise AI-Erweiterung:
1. **Phase 1:** AI meidet Pfade durch feindliche Schildlinien (Pfadkosten-Berechnung)
2. **Phase 2:** AI baut Schildlinien an Frontlinien (Fortress-Taktik priorisiert)
3. **Phase 3:** AI baut Stationen (Rush: offensiv, Fortress: defensiv)
4. **Phase 4:** AI reagiert auf feindliche Stationen (Scan + Zerstorung)

### 8.5 Risiko: Signatur-Tuning

**Problem:** `STATION_SIGNATURE_PER_SHIP = 10px` konnte zu niedrig oder zu hoch sein:
- **Zu niedrig:** Stationen mit 20+ Garnison bleiben unsichtbar -> "unsichtbare Festungen" dominieren
- **Zu hoch:** Jede Garnison verrat die Station sofort -> Stealth-Aspekt verliert Bedeutung

**Analyse:** Bei 10px/Schiff ist eine 20-Fighter-Garnison bei 200px sichtbar, was dem passiven Scan-Radius von Sternen entspricht. Das bedeutet: eine moderat garnisierte Station wird von Nachbarsternen (typische Distanz 150-250px) mit hoher Wahrscheinlichkeit entdeckt. Nur leere oder schwach garnisierte Stationen (<10 Schiffe) bleiben verborgen.

**STATION_BUILD_SIGNATURE = 30px** ist bewusst niedrig gehalten. Nur Sterne/Stationen in unmittelbarer Nahe (<30px) entdecken eine Station im Bau. Das ermoglicht verdeckten Stationsbau in Lucken des feindlichen Scan-Netzwerks, was strategisch gewunscht ist.

**Empfehlung:** 10px/Schiff als Startwert beibehalten, durch Playtesting validieren. Wenn "Just-in-Time"-Garnisonierung (Schiffe erst kurz vor Angriff schicken) zu dominant wird, auf 15-20px erhohen.

### 8.6 Risiko: Kleine vs grosse Reiche

**Problem:** Das Design bevorzugt explizit kleine, kompakte Reiche (kurze Distanzen = starke Schilder, 2 Strukturen reichen, 3 Stationen = volle Offensivkapazitat). Grosse Reiche haben mehr Lucken als Strukturen schliessen konnen.

**Bewertung:** Dies ist **beabsichtigt** als Anti-Snowball-Mechanik (zusammen mit Rebellion). Ein dominanter Spieler hat:
- Mehr Systeme zu verteidigen
- Rebellionsgefahr
- Mehr Schildlinien-Lucken
- Gleiche Anzahl Stationen/Strukturen wie der Underdog

**Empfehlung:** Parameter-Tuning uber Playtesting. Falls grosse Reiche zu stark benachteiligt werden, `MAX_SHIELD_STRUCTURES` auf 3 erhohen.

---

## 9. Gesamtbewertung

### 9.1 Balance-Scorecard

| Dimension | Ohne FUT-19/20 | Mit FUT-19/20 | Tendenz |
|-----------|---------------|---------------|---------|
| Strategische Tiefe | Mittel | Hoch | Deutliche Verbesserung |
| Offense/Defense-Balance | Leicht defensiv | Stark defensiv | Erfordert Monitoring |
| Snowball-Kontrolle | Gut (Rebellion) | Sehr gut (Rebellion + Schildbruch) | Verbesserung |
| Stalemate-Risiko | Mittel-Hoch | Mittel (dank Stationen) | Leichte Verbesserung |
| Taktik-Vielfalt | 5 Taktiken, akzeptabel | Mehr Entscheidungen, besser | Verbesserung |
| Information-Asymmetrie | Gering (nur FoW) | Hoch (Signatur, Scan, Stealth) | Deutliche Verbesserung |
| Komplexitat | Moderat | Hoch | Erfordert gute UI/UX |
| AI-Qualitat | Akzeptabel | Erfordert signifikante Erweiterung | Risiko |

### 9.2 Empfohlene Implementierungsreihenfolge

1. **FUT-19 zuerst** (Schildlinien) -- schafft das territoriale Fundament
2. **FUT-20 direkt danach** (Stationen) -- liefert den Counter gegen Turtle-Meta
3. **AI-Erweiterung parallel** -- ohne AI-Support sind Schildlinien nur fur Human-Spieler nutzbar
4. **Parameter-Tuning durch Playtesting** -- insbesondere SHIELD_DAMAGE_FACTOR und Blockade-Schwellwerte

### 9.3 Kritische Parameter zum Tuning

| Parameter | Startwert | Bereich | Empfindlichkeit |
|-----------|----------|---------|-----------------|
| `SHIELD_DAMAGE_FACTOR` | 0.04 | 0.02-0.06 | **Sehr hoch** -- bestimmt Attrition-Starke |
| `SHIELD_BLOCKADE_THRESHOLD` | 2.5 | 2.0-4.0 | **Hoch** -- bestimmt wann Fighter blockiert werden |
| `SHIELD_BOMBER_RESISTANCE` | 0.5 | 0.3-0.7 | **Mittel** -- bestimmt Bomber-Wert als Counter |
| `MAX_SHIELD_STRUCTURES` | 2 | 2-4 | **Mittel** -- bestimmt territoriale Ausdehnung |
| `STATION_BUILD_COST` | 24 FA | 16-32 | **Mittel** -- bestimmt Stations-Haufigkeit |
| `MAX_STATIONS_PER_PLAYER` | 3 | 2-4 | **Mittel** -- bestimmt offensives Potential |
| `SHIELD_RING_BONUS_INNER` | 0.25 | 0.15-0.35 | **Niedrig** -- Bonus-Feintuning |
| `SHIELD_RING_BONUS_RING` | 0.12 | 0.05-0.20 | **Niedrig** -- Bonus-Feintuning |
| `STATION_SIGNATURE_PER_SHIP` | 10 px/Schiff | 5-20 | **Hoch** -- bestimmt Tarnung vs Sichtbarkeit der Stationen |
| `STATION_BUILD_SIGNATURE` | 30 px | 15-50 | **Mittel** -- Bau-Entdeckungsrisiko |

---

## 10. Zusammenfassung

Das aktuelle Spiel ist **solide balanciert** mit einem leichten Defensiv-Uberhang (Batterien + Verteidigungsbonus). Die Rebellion-Mechanik ist ein effektiver Snowball-Bremser. Bomber haben eine klare Rolle, aber ihre langsame Produktion und Geschwindigkeit begrenzen ihren Einsatz.

**FUT-19 (Schildlinien)** fugt eine dringend benotigte **territoriale Dimension** hinzu. Die Balance-Risiken (Turtle-Meta, Stalemate) sind real, werden aber durch das Design adressiert (Bomber-Resistenz, Rebellion, Max-Strukturen, Aktivierungskosten).

**FUT-20 (Raumstationen)** ist der **essentielle Counter** gegen das von FUT-19 potentiell verstarkte Turtle-Meta. Stationen ermoglichen Flankenangriffe, Staging-Punkte und Informationsasymmetrie. Die hohen Baukosten (24-36 FA) und die begrenzte Anzahl (3) verhindern Missbrauch.

**Stationszerstorung (SS-13a)** erhoht den defensiven Wert von Stationen signifikant: Angreifer verlieren bei erfolgreicher Zerstorung **alle uberlebenden Schiffe**. Das macht Stationsangriffe zu einer Kosten-Nutzen-Abwagung -- lohnt sich die Zerstorung der feindlichen Station den Totalverlust der Angriffsflotte? Kampfberichte (SS-38) und Verlustmeldungen (SS-39) stellen sicher, dass alle Verluste transparent kommuniziert werden.

**Graduierte Sichtbarkeit (SS-09a)** schafft ein neues strategisches Dilemma: **Tarnung vs Kampfkraft**. Die Waffen-Signatur (`garrison × 10px`) sorgt dafur, dass starke Stationen sichtbar werden, wahrend leere oder schwach garnisierte Stationen verborgen bleiben. Das belohnt taktische Entscheidungen wie Just-in-Time-Garnisonierung und macht pauschales "Stealth-Stacking" unmogloch. Die Bau-Signatur (30px) erlaubt weiterhin verdeckten Stationsbau in feindlichen Lucken.

**Beide Features mussen zusammen implementiert werden.** FUT-19 allein wurde das Spiel zu defensiv-lastig machen. FUT-20 allein ergibt ohne Schildlinien wenig Sinn (keine Barriere zum Umgehen).

Die grosste verbleibende Herausforderung ist die **AI-Erweiterung**. Ohne intelligente AI-Nutzung von Schildlinien und Stationen werden diese Features nur Human-Spielern zugute kommen, was die Balance in gemischten Spielen (Human vs AI) verschiebt.
