# Statistik: Bodenatmung
## Aufgaben
- Dokument: 10-15 Seiten
- Einleitung
- mathematische Definitionen
- *Statistische* Begründung (Naturbezug, bzw. Kausalität ist egal)
- *Was* genau macht *welche* R-Funktion?

### Modell erstellen
- Der Datensatz *Bodenatmung* verfügt über viele Varialen. Nur wenige davon sind wirklich aussagekräftig
- Nun kann man eine Vorauswahl treffen und z.B. nur stark Spearsman-korrelierte Varialen ins Modell nehmen
- Achtung: Es gibt sehr viele stat. Abhänigkeiten und der Suchraum in der Varialenselektion wird nur *greedy* sporalisch abgetastet. Es gilt z.B: $P(Temp5|Temp10) \neq P(Temp5) * P(Temp10) $
- das R-Paket `leaps` mit der Funktion `regsubset` wählt automatisch Varialen aus, die die Trainingsdaten gut erklären
- TODO: Was macht `regsubset` genau?
- Man darf auch mal was logarithmieren, wenn man zeigt, dass es die Daten hergibt
### Probleme mit der Vorwärtsselektion mit stupidem F-Test
- hierzu wird in der Regel ein F-Test durchgeführt, der die Hypothese $H_0: \beta_j = 0$ überprüft
- Also: Nullhypothese = Variale $j$ ist unbedeutend
- Dieser F-Wert ist der *Foldchange* der Residuenquadratsumme $RSS$ der Modelle mit und ohne Zusätzlichem Parameter $F=\frac{RSS(M+j) - RSS(M) }{RSS(M)}$
- Ist der Test positiv, so ist die Zunahme der Variable $j$ zum vorherigem Modell signifikant sinnvoll
- Hinzugefügt wird immer die Variable zum Modell, mit dem größtem F-Wert
- Problem: nach vielen Selektionsschritten ist $max(F_i)$ selbst nicht mehr F-verteilt
- Problematisch wird es immer dann, wenn Varialen voneinander statistisch abhänig sind
- Dann ist $F$ nicht gut und man sollte besser $SPSE$ verwenden
### Simulation dieser Problematik
- Erstelle ein Modell, dass die Daten hinreichend gut beschreibt ($SPSE < 0.05$)
- Wähle zufällige Einflussgrößen $x_i$ aus der Designmatrix
- Mache nun weiteren F-Test mit $F=RSS$
- Nun müsste das Modell eigentlich nicht mehr besser werden
- Doch: Es kann auch zufällig vorkommen, dass das Modell besser wird
- Das Modell sollte unabhänig von der zufällig gewählten Zeilen der Designmatrix sein
- Das Ganze ist dann als Fehler zu bezeichnen

## Misc Thoughts
- Es werden zufällige Zeilen der Designmatrix = Zufällige Datensätze (Trainingsdaten) ausgewählt
- Auf dieser ZUfälligen Menge an Beobachtungen wird ein Modell gebaut und Pseudo-Beobachtungen gemacht
- es geht hier nicht im sparse models?
---
- Wir haben viel zu wenige Datensätze und vergleichsweise sehr viele Featurevarialen
- Deswegen müssen wir [Feature Subset Selection](https://de.wikipedia.org/wiki/Feature_Subset_Selection) machen
- Was wir da machen bei der *Vorwärtsselektion* nennt sich *Filter-Ansatz*
- Das ist schnell berechenbar und intuitiv erklärbar (z.B. Es wird x% der Varianz damit erklärt)
- Problem: Redundante Features haben ähnliche *important scores*
- Abhänigkeiten werden ignoriert
- Bsp: Bodentemperatur in 5cm erklärt die Bodenatmung sehr gut. Als nächstes tut der Filter auch gleich die Temp in 10cm mit ins Modell. Das ist Schwachsinn.
