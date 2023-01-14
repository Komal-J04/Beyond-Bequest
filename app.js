//jshint esversion:6
require('dotenv').config();
const express = require("express");
const path = require("path");
const bodyParser = require("body-parser");
const ejs = require("ejs");
const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const saltRounds = 10;

const app = express();
app.use(express.static("public"));

app.set('view engine', 'ejs');
app.use(bodyParser.urlencoded({
  extended: true
}));

app.use('/static', express.static(path.join(__dirname, 'public')));

mongoose.set('strictQuery', true);
mongoose.connect("mongodb+srv://admin:tanisha@cluster0.czauwb5.mongodb.net/bbDB", {useNewUrlParser: true});
const userSchema = new mongoose.Schema ({
    fullname: String,
    phoneNumber: Number,
    AadharNumber: Number,
    email: String,
    password: String,
});
const User = new mongoose.model("User", userSchema);
app.get("/", function(req, res){
  res.render("home");
});
app.get("/login", function(req, res){
  res.render("login");
});
app.get("/register", function(req, res){
  res.render("register");
});

app.post("/register", function(req, res){

  bcrypt.hash(req.body.password, saltRounds, function(err, hash) {
    const newUser =  new User({
        fullname: req.body.fullName,
        phoneNumber: req.body.phoneNumber,
        AadharNumber: req.body.aadharNumber,
        email: req.body.email,
        password: hash
    });
    newUser.save(function(err){
      if (err) {
        console.log(err);
      } else {
        res.render("dashboard");
      }
    });
  });

});

app.post("/login", function(req, res){
  const phoneNumber = req.body.phoneNumber;
  const password = req.body.password;

  User.findOne({phoneNumber: phoneNumber}, function(err, foundUser){
    if (err) {
      console.log(err);
    } else {
      if (foundUser) {
        bcrypt.compare(password, foundUser.password, function(err, result) {
          if (result === true) {
            res.render("dashboard");
          } 
        });
      }
    }
  });
});
app.listen(3000, function() {
  console.log("Server started on port 3000.");
});