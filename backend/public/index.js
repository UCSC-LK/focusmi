
/*--------------------------main api page---------------------------------*/
//libraries
let express= require("express")
let app = express();
let cookieParser = require('cookie-parser');
let path = require("path");
let cors = require("cors");
let bodyParser = require('body-parser');
let dotenv = require("dotenv");
let WebSocket = require('ws')
let moment =require('moment')
let  {verify} = require('jsonwebtoken');
const dbmodel = require("../models/core/dbmodel");
const authRoutes = require("../routes/user_auth");
const authRouterTherapist = require("../routes/therapist_auth")
const ScheduleRouter = require('../routes/schedule')
const pool = require("../database/dbconnection");
const gTaskRoutes = require("../routes/group_task_planner");
const {task_group} = require("../sequelize/models");
const assetRouter = require("../routes/asset_routes");
const appointmentRouter = require("../routes/appointment"); 
const userTRoutes = require("../routes/adminitrator");
const mRouter = require("../routes/mindfulness_courses");
const nRouter = require("../routes/notification_routes");
const dRouter = require("../routes/daily_tips");

dotenv.config()

/* ************
/**middleware********* */
//cookie handlding
app.use(cookieParser());


app.use(cors())
app.use(express.json())
app.use(express.urlencoded({extended: true}))//url encoded bodies)
app.use(bodyParser.json())
app.use(express.static('public'))

//all routes
app.use(assetRouter)
app.use(authRoutes)
app.use(gTaskRoutes)
app.use(authRouterTherapist)
app.use(ScheduleRouter)
app.use(appointmentRouter)
app.use(userTRoutes)
app.use(mRouter)
app.use(nRouter)
app.use(dRouter)




const PORT = process.env.PORT || 3000

//connection

app.listen(PORT,() => console.log(`Server has started on ${PORT}`))
var  webSockets = {}
const wss = new WebSocket.Server({ port: 6060 }) //run websocket server with port 6060
wss.on('connection', function (ws, req)  {
    var userID = req.url.substr(1) //get userid from URL ip:6060/userid 
    webSockets[userID] = ws //add new user to the connection list

    console.log('User ' + userID + ' Connected ') 

    ws.on('message', message => { //if there is any message
        console.log(message);
        var datastring = message.toString();
        if(datastring.charAt(0) == "{"){
            datastring = datastring.replace(/\'/g, '"');
            var data = JSON.parse(datastring)
            if(data.auth == "chatapphdfgjd34534hjdfk"){
                if(data.cmd == 'send'){ 
                    var boardws = webSockets[222] //check if there is reciever connection
                    if (boardws){
                        var cdata = "{'cmd':'" + data.cmd + "','userid':'"+data.userid+"', 'msgtext':'"+data.msgtext+"'}";
                       wss.clients.forEach(function each(client) {
                        console.log("Dfdf")
                            if (client !== ws && client.readyState === WebSocket.OPEN) {
                                client.send(cdata);
                            }
                            });
                        ws.send(data.cmd + ":success");
                    }else{
                        console.log("No reciever user found.");
                        ws.send(data.cmd + ":error");
                    }
                }else{
                    console.log("No send command");
                    ws.send(data.cmd + ":error");
                }
            }else{
                console.log("App Authincation error");
                ws.send(data.cmd + ":error");
            }
        }else{
            console.log("Non JSON type data");
            ws.send(data.cmd + ":error");
        }
    })

    ws.on('close', function () {
        var userID = req.url.substr(1)
        delete webSockets[userID] //on connection close, remove reciver from connection list
        console.log('User Disconnected: ' + userID)
    })
    
    ws.send('connected'); //innitial connection return message
})