#Collection Musician

db.musician.insertMany([
  {
    ssn: 'M001',
    name: 'Alice',
    address: 'Bangalore',
    phone: 8745214523,
    iuin: [ 1, 5, 8 ],
    sid: [ 'S005', 'S004' ]
  },
  {
    ssn: 'M002',
    name: 'Bob',
    address: 'Chennai',
    phone: 9874532145,
    iuin: [ 3, 8 ],
    sid: [ 'S002', 'S001', 'S006' ]
  },
  {
    ssn: 'M003',
    name: 'Tommy',
    address: 'Mysore',
    phone: 8745632145,
    iuin: [ 1 ],
    sid: [ 'S001', 'S002' ]
  },
  {
    ssn: 'M004',
    name: 'Krish',
    address: 'Trichy',
    phone: 9874521456,
    iuin: [ 5, 3, 8, 1 ],
    sid: [ 'S002', 'S001', 'S003' ]
  }
])

#Collection Album

db.album.insertMany([
  {
    auin: 'A001',
    title: 'Album 1',
    date: '2001-5-23',
    format: 'CD',
    sid: [ 'S001', 'S002', 'S006' ],
    producer: 'M004'
  },
  {
    auin: 'A002',
    title: 'Album 2',
    date: '2010-9-13',
    format: 'MC',
    sid: [ 'S003', 'S004', 'S005' ],
    producer: 'M001'
  }
])

#Collection Song

db.song.insertMany([
  {
    sid: 'S001',
    stitle: 'Title 1',
    author: 'author 1'
  },
  {
    sid: 'S002',
    stitle: 'Title 2',
    author: 'author 2'
  },
  {
    sid: 'S003',
    stitle: 'Title 3',
    author: 'author 3'
  },
  {
    sid: 'S004',
    stitle: 'Title 4',
    author: 'author 4'
  },
  {
    sid: 'S005',
    stitle: 'Title 5',
    author: 'author 5'
  }
])

#Collection Instrument

db.instrument.insertMany([
  {
    iuin: 1,
    name: 'guitar',
    key: 'CDGA'
  },
  {
    iuin: 3,
    name: 'piano',
    key: 'CDGF'
  },
  {
    iuin: 5,
    name: 'drums',
    key: 'CDG'
  },
  {
    iuin: 8,
    name: 'flute',
    key: 'CDG'
  }
])

#Queries

1. List musician name, title of the song which he has played, the album in which song has occurred.

db.musician.aggregate([
  {
    $lookup: {
      from: "song",
      localField: "sid",
      foreignField: "sid",
      as: "songs"
    }
  },
  {
    $unwind: "$songs"
  },
  {
    $lookup: {
      from: "album",
      localField: "songs.sid",
      foreignField: "sid",
      as: "albums"
    }
  },
  {
    $project: {
      _id: 0,
      name: 1,
      album: "$albums.title",
      song: "$songs.stitle"
    }
  },
  {
    $group: {
      _id: {
        name: "$name",
        album: "$album"
      },
      songs: { $addToSet: "$song" }
    }
  },
  {
    $group: {
      _id: "$_id.name",
      albums: {
        $push: {
          name: "$_id.album",
          songs: "$songs"
        }
      }
    }
  },
  {
    $project: {
      _id: 0,
      name: "$_id",
      albums: 1
    }
  }
])

2. Retrieve the name of Musician who have not produced any Album

db.musician.find({ ssn: { $nin: db.album.distinct("producer") } })

3. List the details of songs which are performed by more than 2 musicians.

db.song.aggregate([ { $lookup: { from: "musician", localField: "sid", foreignField: "sid", as: "musicians" } }, { $project: { _id: 0, sid: 1, stitle: 1, author: 1, numMusicians: { $size: "$musicians" } } }, { $match: { numMusicians: { $gt: 2 } } }] )

4. List the different instruments played by the musicians and the average number of musicians who play the instrument.

db.musician.aggregate([
  {
    $unwind: "$iuin" // Unwind the array of instruments
  },
  {
    $group: {
      _id: "$iuin",
      count: { $sum: 1 } // Count the number of musicians for each instrument
    }
  },
  {
    $lookup: {
      from: "instrument",
      localField: "_id",
      foreignField: "iuin",
      as: "instrumentDetails"
    }
  },
  {
    $project: {
      instrument: "$instrumentDetails.name", // Get the instrument name
      averageMusicians: { $divide: ["$count", db.musician.count()] } // Calculate the average
    }
  }
])

5.Retrieve album title produced by the producer who plays guitar as well as flute and has produced no of songs greater than or equal to the average songs produced by all producers.

 const producersList = db.album.distinct("producer");

 const instrument_to_have = db.instrument.distinct("iuin", { name: { $in: ["flute", "guitar"] } });

 const producerList = db.musician.distinct("ssn", { ssn: { $in: producersList }, iuin: { $all: instrument_to_have } });

 const minSidCount = db.album.aggregate([ { $group: { _id: "$producer", totalSongs: { $sum: { $size: "$sid" } } } }, { $group: { _id: null, avgSongsProduced: { $avg: "$totalSongs" } } }, { $project: { _id: 0, avgSongsProduced: 1 } }] ).next().avgSongsProduced;

 db.musician.aggregate([ { $match: { ssn: { $in: producersList }, $expr: { $gte: [{ $size: "$sid" }, minSidCount] } } }, { $project: { _id: 0, name: 1, sidCount: { $size: "$sid" } } }] )

6. List the details of musicians who can play all the instruments present


db.musician.find({
  iuin: { $all: db.instrument.distinct("iuin") }
})
