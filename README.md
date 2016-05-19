# Unical_tools

UniPhoneScraper usage

nel file uniphonescraper.py basta modificare la variabile

    _struttura = "Dipartimento di Ingegneria per l'Ambiente e il Territorio e Ingegneria Chimica"

con il valore che desideriamo interrogare nella rubrica di ateneo. Dopodichè:

    python uniphonescraper.py

se volessimo possiamo anche evitare di modificare il file uniphonescraper.py indicando al comando
la struttura che desideriamo estrarre

    python uniphonescraper.py ["Nome della struttura tra virgolette"]

esempio:

    python uniphonescraper.py "Centro Linguistico di Ateneo"


questo comando stampa a schermo in formato CSV (estraendolo da JSON) il risultato. UniPhoneScraper funziona con due classi, facilmente
estendibili ed integrabili in progetti terzi.

Fin quando la struttura dell' html della
rubrica di http://www.unical.it rimarrà invariata la procedura funzionerà a dovere.
