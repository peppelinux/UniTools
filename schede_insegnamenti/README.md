Requirements (pip install):
=============================
BeautifulSoup


Usage:
=============================
python download_json_insegnamenti.py nomefile_output.json


Hints
=============================

The index number from insegnamenti object could be used to forge a specific http request, like, for example:

http://www.unical.it/portale/portaltemplates/view/view_scheda_insegnamento.cfm?2962

insegnamenti['insegnamentos'][0]
u'{"value":"2962", "label":"27000326  - ABILITA LINGUISTICHE - Doc. DAVOLI Denise Dolores (CdS 0767 GENERICO )"}'

