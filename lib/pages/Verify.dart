/*body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (BuildContext context,AsyncSnapshot snapshot){
          if(snapshot.hasError)
          {
            return Center(child: Text('Some error'),)
          }
          if(snapshot.hasData){
            QuerySnapshot querySnapshot=snapshot.data;
            List<QueryDocumentSnapshot> documents=querySnapshot.docs;

            List<Map> items=documents.map((e) => {
              'name': e['name'],
              'date': e['date'],
              'location': e['location'],
              'price': e['price'],
            }).toList();

            
          }
          return Center(child: CircularProgressIndicator());
          
        }
      )*/