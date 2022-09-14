const vader = require('vader-sentiment');
// const MONGODB_URI = process.env.CONNECTIONSTRING || '';

// const MongoClient = require("mongodb").MongoClient;

// let cachedDb = null;

// async function connectToDatabase() {
//   if (cachedDb) {
//     return cachedDb;
//   }

//   // Connect to our MongoDB database hosted on MongoDB Atlas
//   const client = await MongoClient.connect(MONGODB_URI);

//   // Specify which database we want to use
//   const db = await client.db("test");

//   cachedDb = db;
//   return db;
// }

exports.handler = async (event, context) => {
    context.callbackWaitsForEmptyEventLoop = false;

    // Get an instance of our database
    // const db = await connectToDatabase();
    
    // if (event.httpMethod === 'GET') {
    // const sentimentCollection = await db.collection("sentiment").find({}).limit(20).toArray();
    // return {
    //     statusCode: 200,
    //     body: JSON.stringify(sentimentCollection)
    // };
    // }
    // else 
    if (event.httpMethod === 'PUT') {
        const body = JSON.parse(event.body);
        const intensity = vader.SentimentIntensityAnalyzer.polarity_scores(body.input);
        // const result = await db.collection("sentiment").insertOne({input: body.input, intensity: intensity});
        return {
            statusCode: 200,
            body: JSON.stringify(intensity)
        };
    }
    else {
        return {
            statusCode: 404,
            body: "Not Found"
        };
    }
};