from pathlib import Path
import json

STAGE=Path(__file__).resolve().parent/'.forest-mushrooms-work'
def node(player,text,**responses):
    return {'player_text':player,'text':text,'responses':{k:{'text':v} for k,v in responses.items()}}

nodes={
'en':{
 'knife_mushroom_intro':node('Why the knife?',
    'Locals. Baskets. Smiling locals with baskets. Tell me... do you like eating mushrooms?',
    yes='Yes. Especially fried with butter.',no='No. I prefer my food less conversational.',leave='I should keep moving.'),
 'knife_mushroom_relief':node('I am not here to pick you.',
    'Good. Neither am I. We understand each other.',leave='Perfectly. Nice knife.'),
 'wise_mushroom_intro':node('A talking mushroom?',
    'Only when necessary. Apparently this is one of those occasions.',
    ask_metsavana='What is wrong with Metsavana?',ask_ink='Where can I get ink?',ask_knife='Why does that mushroom have a knife?',leave='I will leave you in peace.'),
 'wise_mushroom_metsavana':node('Is Metsavana asleep?',
    'In a trance. The gnomes keep him clean and fed. An excellent arrangement, unless you are a gnome.',
    ask_gnomes='What do the gnomes get out of it?',back='I had another question.'),
 'wise_mushroom_gnomes':node('Do they get anything in return?',
    'Wisdom. Shelter. The occasional root to trip over. He calls it a benefits package.',back='That explains the silence.'),
 'wise_mushroom_ink':node('I need ink for Hendrik.',
    'Touch the purple mushroom beside me. One bottle of ink, no appointment. Writing material, not lunch. An important distinction.',leave='Purple mushroom. Touch. No licking. Understood.'),
 'wise_mushroom_knife':node('That fellow looks nervous.',
    'People arrive with baskets. He has developed a pointed objection. Avoid discussing dinner.',back='I will choose my words carefully.'),
 'wise_mushroom_after_ink':node('I have the ink.',
    'Then take it to Hendrik. Put it on paper. Humans have needed that clarified before.',ask_metsavana='One last question about Metsavana...',leave='Ink on paper. I can manage that.'),
 'purple_mushroom_silent':node('Can you help me?',
    'The purple mushroom quietly wobbles. The wise mushroom gestures for you to touch it.',leave='I will try that.')},
'es':{
 'knife_mushroom_intro':node('¿Por qué llevas un cuchillo?',
    'Los vecinos. Las cestas. Vecinos sonrientes con cestas. Dime... ¿te gusta comer setas?',
    yes='Sí. Sobre todo fritas con mantequilla.',no='No. Prefiero que mi comida hable menos.',leave='Será mejor que siga andando.'),
 'knife_mushroom_relief':node('No he venido a recogerte.',
    'Bien. Yo tampoco. Nos entendemos.',leave='Perfectamente. Bonito cuchillo.'),
 'wise_mushroom_intro':node('¿Una seta que habla?',
    'Solo cuando es necesario. Al parecer, esta es una de esas ocasiones.',ask_metsavana='¿Qué le pasa a Metsavana?',ask_ink='¿Dónde consigo tinta?',ask_knife='¿Por qué esa seta lleva un cuchillo?',leave='Te dejaré en paz.'),
 'wise_mushroom_metsavana':node('¿Metsavana está dormido?',
    'Está en trance. Los gnomos lo mantienen limpio y alimentado. Un acuerdo excelente, salvo si eres un gnomo.',ask_gnomes='¿Y qué ganan los gnomos?',back='Tenía otra pregunta.'),
 'wise_mushroom_gnomes':node('¿Reciben algo a cambio?',
    'Sabiduría. Cobijo. Alguna raíz con la que tropezar. Él lo llama un paquete de beneficios.',back='Eso explica el silencio.'),
 'wise_mushroom_ink':node('Necesito tinta para Hendrik.',
    'Toca la seta morada a mi lado. Un frasco de tinta, sin cita previa. Material de escritura, no el almuerzo. Una distinción importante.',leave='Seta morada. Tocar. Nada de lamer. Entendido.'),
 'wise_mushroom_knife':node('Ese tipo parece nervioso.',
    'La gente viene con cestas. Ha desarrollado una objeción muy afilada. Evita hablar de la cena.',back='Elegiré mis palabras con cuidado.'),
 'wise_mushroom_after_ink':node('Ya tengo la tinta.',
    'Entonces llévasela a Hendrik. Ponla sobre papel. Otros humanos han necesitado esa aclaración.',ask_metsavana='Una última pregunta sobre Metsavana...',leave='Tinta sobre papel. Eso puedo hacerlo.'),
 'purple_mushroom_silent':node('¿Puedes ayudarme?',
    'La seta morada se balancea en silencio. La seta sabia te indica que la toques.',leave='Lo intentaré.')},
'ee':{
 'knife_mushroom_intro':node('Milleks sulle nuga?',
    'Kohalikud. Korvid. Naeratavad kohalikud korvidega. Ütle... kas sulle meeldib seeni süüa?',
    yes='Jah. Eriti võis praetult.',no='Ei. Eelistan vähem jutukat toitu.',leave='Ma lähen parem edasi.'),
 'knife_mushroom_relief':node('Ma ei tulnud sind korjama.',
    'Hea. Mina ka mitte. Me mõistame teineteist.',leave='Täielikult. Ilus nuga.'),
 'wise_mushroom_intro':node('Rääkiv seen?',
    'Ainult siis, kui vaja. Ilmselt on praegu üks neist kordadest.',ask_metsavana='Mis Metsavanal viga on?',ask_ink='Kust ma tinti saan?',ask_knife='Miks sellel seenel nuga on?',leave='Jätan su rahule.'),
 'wise_mushroom_metsavana':node('Kas Metsavana magab?',
    'Ta on transis. Päkapikud hoiavad ta puhta ja söönuna. Suurepärane korraldus, kui sa just päkapikk pole.',ask_gnomes='Mida päkapikud sellest saavad?',back='Mul oli veel üks küsimus.'),
 'wise_mushroom_gnomes':node('Kas nad saavad midagi vastu?',
    'Tarkust. Peavarju. Mõne juure, mille otsa komistada. Tema nimetab seda hüvede paketiks.',back='See selgitab vaikimist.'),
 'wise_mushroom_ink':node('Mul on Hendrikule tinti vaja.',
    'Puuduta lillat seent mu kõrval. Pudel tinti, aega pole vaja kinni panna. Kirjutamiseks, mitte lõunaks. Oluline vahe.',leave='Lilla seen. Puudutada. Mitte lakkuda. Selge.'),
 'wise_mushroom_knife':node('See tegelane paistab närviline.',
    'Inimesed tulevad korvidega. Tema vastuväide on muutunud teravaks. Ära õhtusöögist räägi.',back='Valin oma sõnu hoolikalt.'),
 'wise_mushroom_after_ink':node('Tint on käes.',
    'Siis vii see Hendrikule. Pane see paberile. Inimestele on tulnud seda varemgi selgitada.',ask_metsavana='Üks viimane küsimus Metsavana kohta...',leave='Tint paberile. Sellega saan hakkama.'),
 'purple_mushroom_silent':node('Kas sa saad mind aidata?',
    'Lilla seen kõigub vaikselt. Tark seen viipab, et sa seda puudutaksid.',leave='Proovin järele.')}
}
messages={
'en':{'knife_mushroom_look':'A small mushroom with a knife and a very large trust issue.',
      'knife_mushroom_touch':'He tightens his grip on the knife. Touching him seems unwise.',
      'inkcap_collected':'You collect a bottle of ink from the purple mushroom. Hendrik can use this.',
      'inkcap_already_collected':'You already collected the ink. The mushroom is not a refill station.'},
'es':{'knife_mushroom_look':'Una seta pequeña con un cuchillo y un enorme problema de confianza.',
      'knife_mushroom_touch':'Aprieta el cuchillo. Tocarla no parece buena idea.',
      'inkcap_collected':'Recoges un frasco de tinta de la seta morada. Le servirá a Hendrik.',
      'inkcap_already_collected':'Ya recogiste la tinta. La seta no es una estación de recarga.'},
'ee':{'knife_mushroom_look':'Väike seen noa ja väga suure usaldusprobleemiga.',
      'knife_mushroom_touch':'Ta haarab noast kõvemini. Puudutamine ei tundu tark tegu.',
      'inkcap_collected':'Saad lillalt seenelt pudeli tinti. Hendrikul on sellest kasu.',
      'inkcap_already_collected':'Tint on sul juba käes. Seen ei ole täitejaam.'}
}
for locale in nodes:
    path=STAGE/'resources'/'translations'/f'{locale}.json'
    t=json.loads(path.read_text(encoding='utf-8-sig'))
    t['dialogues'].update(nodes[locale])
    t['messages'].update({k:{'text':v} for k,v in messages[locale].items()})
    names={'en':('Wise mushroom','Purple mushroom','Nervous mushroom'),
           'es':('Seta sabia','Seta morada','Seta nerviosa'),
           'ee':('Tark seen','Lilla seen','Närviline seen')}[locale]
    for key,name in zip(('forest_mushroom','inkcap','knife_mushroom'),names):
        t['actors'][key]={'name':name};t.setdefault('scene',{})[key]=name
    path.write_text(json.dumps(t,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Wrote forest mushroom dialogue in English, Spanish and Estonian.')
