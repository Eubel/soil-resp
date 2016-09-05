# Doc-Draft

Unsere Arbeit - in Stichpunkten und Nussschalen

## Einleitung

### Bodenatmung als geophysikalischer Prozess
- $CO_2$-Konzentration ist emminenter Bestandteil von Klimamodellen
- Bodenatmung wichtigster Prozess auf Landgebiet
- 30% der weltweiten Landfläche ist bewaldet
- Nationalpark Hainich als lokales Beispiel für Wälder in der gemäßigten Klimazone

### Der Datensatz

- 38 Messwerte, 33 Variabeln
- Viel zu wenig Messwerte, um alle Variabeln statistisch begründen zu können -> Reduktion der Featuremenge notwendig
- Viele statistische Abhänigkeiten verringern außerdem den statistischen Informaionsgehalt ($Temp_5$ bringt nur marginalen Mehrwert, wenn man $Temp_{10}$ bereits gemessen hat)

### Vorgehen

- Variabelnselektion
  - Unkorrelierte Variabeln aussortieren
  - nicht normalverteilte Variabeln aussortieren (Verteilung ist Bedingung in vielen stat. Tests)
  - Überprüfung auf Affinität (mögliche Linkfunktionen für pH,Temp und moisture)
- Erstellung des Modells
    - Wahl der 5 best korrelierten Variabeln
    - Erstellung eines linearen Modells
    - Partitionierung: 80% Training / 20% Test

### Statistische Grundlagen

- Fehler
  - SPSE
  - RSS
- Informationskriterien in der Variabelnselektion
  - AIC
  - BIC
- Korrelation
  - Notwendig für Kausalität
  - Maß für Anteil der erklärten Varianz am Modell
  - Quadrierter Korrelationskoeffizient als Bestimmtheitsmaß $R^2$ in linearen Modellen (Anteil erklärter Varianz des Modells)
  - Pearson vs. Spearman
- Shapiro-Test
  - Test auf Normalverteilung
- F-Test in verschachtelten Modellen
  - Test auf signifikantem Unterschied zweier Modelle mit verschachtelten Featuremengen
  - Wird der Fehler $RSS$ wirklich so stark reduziert, dass es sich lohnt, die Freiheitsgrade des Modells zu erhöhen?
  - anova

## Erstellung eines statistischen Modells

- Daten: hainich.csv, A. Soe, MPI Biogeochemie
- Programmierumgebung: R
- Variabelnselektion `hainich-variablenselektion.r`

### Pearson-Korrelation (fig/correlation-pearson.png)

- *lmoi* und *temp.15* korrelieren sehr stark
- die besten 8 sind (*lmoi*, *temp.15*, *litdoc*, *litter.d*, *smoi*, *rootdw0*, *temp.0*, *soiln0*)
- die untere Schranke ist *soiln0* mit 0.28408188

~~~
hainich.pear <- abs(cor(hainich))["soil.res",-1]
~~~

### Shapiro-Filter (fig/normalverteilung-shapiro.png)

- von den 8 Varaiablen die am besten mit *soli.resp* korrelieren sind 4 normalverteilt (p-Value > 0.05)
- übrig bleiben *lmoi*, *temp.15*, *smoi*, *soiln0*)
- vermutet, aber keine Korrelation zwischen *lmoi* und *smoi* vorhanden

~~~
hainich.shapiro <- mapply(function(x) shapiro.test(x)$p.value,hainich)
~~~

### Variablenselektion mit "forward selection" (fig/variablenselektion-bic-adjr2.png)

- Sampling der Daten auf test/Train
- R-Paket `leaps` und Funktion `regsubsets`
- Ergebnis: `soil.res ~ 1 + lmoi + temp.15 + smoi`
~~~
library("leaps")
hainich.leaps <- regsubsets(soil.res ~ 1 + lmoi + temp.15 + smoi + soiln0,
                             data=hainich.train, method = "forward")
~~~

### Training des linearen Modells mit `lm(...)`

## Simulation und Fehlerabschätzung

- Beim F-Test wird die Hypothese überprüft, ob eine zusätzliche Featurevariabel den Fehler $RSS$ signifikant im Bezug auf die zusätzlichen Freiheitsgrade verbessert
- Das kann zu Fehlentscheidungen führen, da maximale $F$-Werte nicht zwangsläufig zu minimalen direkten Fehlern $SPSE$ führen
- Das kann mehrere Gründe haben:
  - F-Test fordert Normalverteilung. Das ist nicht immer gegeben
  - Gemesse Features sind nicht aussagekräftig
  - Datenerhebung fehlerhaft
  - Stat. Abhänigkeiten von Variabeln verzerren Ergebnis
  - Test kann auch nur zufällig richtig sein (p-Value?)
- Vorhergensweise
  - gegeben: Vorher erstelltes Model, welches als "wahr" angesehen werden kann
  - Partioniere Datensatz in Test und Train (Kreuzpartitionierung oder zufällig mittels Monte-Carlo)
  - Versuche ein weiteres mögliches Feature hinzuzunehmen
  - Überprüfe, ob die Entscheidung mit maximalem F-Wert auch das Modell mit geringstem Fehler $SPSE$ ist. Wenn dies nicht der Fall ist, liegt eine Fehlentscheidung vor.
  - Die Häufigkeit der Fehlentscheidung ist eine Schätzung für die Wahrscheinlcihkeit Fehlentscheidungen bei der Nullhypothese
- Auswertung
  - Schätze Wahrscheinlichkeit zur Fehlentscheidung von $H_0$
  - Überprüfung mittels Kerneldichte: Sind die F-Werte auch f-verteilt?
  - Waren die Entscheidungen knapp?

## Diskussion

- Wir haben zur Simulation und zur Modellerstellung dieselben Daten evrwendxet. Das ist statistisch unsauber.
- Um jeden Datenpunkt möglichst nur einmal zu verwednen, wurde Kreuzpartionierung angewandt. Monte-Carlo-Ansatz widerspricht diesem Aspekt. Er ist allerdings nötig, um die Wahrscheinlichkeit genauer abschätzen zu können. Sonst hätte man bei n-facher Kreuzpartionierung nur n Werte zur Bestimmung der Wahrscheinlichkeit

## Zusammenfassung

- Wie gut lässt sich ein Modell mit so wenig Daten bauen?
- Wie oft trifft der F-Test Fehlentscheidungen?

![fig/correlation-pearson.png](fig/correlation-pearson.png)

![fig/scatterplot-pearson-top8.png](fig/scatterplot-pearson-top8.png)

![fig/normalverteilung-shapiro.png](fig/normalverteilung-shapiro.png)

![fig/scatterplot-pearson-normalverteilt.png](fig/scatterplot-pearson-normalverteilt.png)

![fig/variablenselektion-bic-adjr2.png](fig/variablenselektion-bic-adjr2.png)

