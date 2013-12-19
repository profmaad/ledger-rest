import ledger
import json
import sys

filename = sys.argv[1]
query = sys.argv[2]

transactions = []
last_xact = None
for match in ledger.read_journal(filename).query(query):
    if match.xact != last_xact:
        transaction = {}
        transaction['payee'] = match.xact.payee
        transaction['date'] = str(match.xact.date)

        if match.xact.code != None:
            transaction['code'] = match.xact.code

        if match.xact.note != None:
            transaction['note'] = match.xact.note.strip()

        if match.xact.aux_date != None:
            transaction['aux_date'] = str(match.xact.aux_date)

        if str(match.xact.state) == 'Cleared':
            transaction['cleared'] = True
            transaction['pending'] = False
        elif str(match.xact.state) == 'Cleared':
            transaction['cleared'] = False
            transaction['pending'] = True
        else:
            transaction['cleared'] = False
            transaction['pending'] = False

        transaction['posts'] = []
        for post in match.xact.posts():
            new_post = {}
            new_post['account'] = str(post.account)
            new_post['amount'] = float(post.amount)
            new_post['commodity'] = str(post.amount.commodity)
            transaction['posts'].append(new_post)

        transactions.append(transaction)

        last_xact = match.xact

print json.dumps(transactions)
