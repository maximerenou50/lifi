const express = require("express");
const bodyParser = require('body-parser');
const app = express();
const AWS = require("aws-sdk");
const { v4: uuidv4 } = require('uuid');

// App configuration
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());

app.listen(3000, () => {
    console.log("Server running on port 3000");
});

// DynamoDB
AWS.config.update({ region: 'eu-central-1' });
const DynamoDB = new AWS.DynamoDB();
const ddbTableID = process.env.DDB_TABLE_ID

// REST API
app.get("/status", (_, res) => {
    res.json({ "status": "running" });
});

app.get("/data", (_, res) => {
    const ddbParams = {
        TableName: ddbTableID,
    };

    DynamoDB.scan(ddbParams, function(err, data) {
        if (err) {
            res.end(JSON.stringify(("Unable to scan", err)));
        } else {
            res.end(JSON.stringify((data.Items)));
        }
    });
})

app.post("/data", (req, res) => {
    const ddbParams = {
        TableName: ddbTableID,
        Item: {
            id: { S: uuidv4() },
            data: { S: JSON.stringify(req.body) },
        },
    };

    DynamoDB.putItem(ddbParams, function(err) {
        if (err) {
            res.end(JSON.stringify(("Unable to add a new item", err)));
        } else {
            res.end(JSON.stringify("Data saved to DynamoDB"));
        }
    });

})

app.delete("/data/:id", (req, res) => {
    const ddbParams = {
        TableName: ddbTableID,
        Key: {
            id: { S: req.params.id },
        },
    };

    DynamoDB.deleteItem(ddbParams, function(err) {
        if (err) {
            res.end(JSON.stringify(("Unable to delete the item", err)));
        } else {
            res.end(JSON.stringify("Data deleted to DynamoDB"));
        }
    });

})