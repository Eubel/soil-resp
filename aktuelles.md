# Aktuelles

## Verständnis-Fragen
- Wozu sollen Pseudobeobachtungen simuliert werden? Sollen sie mit den Messwerten für `soil.resp` ersetzt werden, um das "wahre" Modell "noch wahrer" werden zu lassen?
- ist mit zufällig ausgewählten Zeilen gemeint, dass man einfach den Trainingsdatensatz samplet?
- Warum soll eine Häufigkeitsverteilung des Maximums erstellt werden? Ist es nicht völlig egal, welchen Wert das maximale F hat? Es geht doch eigentlich nur darum, wie alle F-Werte an sich verteilt sind (für jeden zusätzlichen Feature ein F-Wert)? Das muss dann F-verteilt werden.
- Ist die Wahrscheinlichkeit zur fälschlichen Ablehnung der Nullhypothese dann einfach dadurch geschätzt, dass man die relative Häufigkeit der Fälle mit $\min(SPSE) \neq \max(F)$ nimmt, wenn man mehrfach die Variabelnselektion bei zufälligen Untermengen der Messwerte durchführt?
