/*
==========================================
CREATE DATABASE SCHEMA
==========================================

This script will create database schema based on medallion architecture. The script sets up three 
schemas within the database: 'bronze', 'silver', and 'gold',after checking if schema exists or not.
*/

CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;