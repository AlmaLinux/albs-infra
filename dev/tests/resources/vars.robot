*** Variables ***

${HOST}                 albs
${PORT}                 8080
${BROWSER}              Chrome
${DELAY}                0.5
${LOGIN TOKEN}          albs=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiMSIsImF1ZCI6WyJmYXN0YXBpLXVzZXJzOmF1dGgiXSwiZXhwIjo5OTk5OTk5OTk5fQ.kaXYYzSEPJX03dNBxNMHN5eyArJpP01vvih60dKDk4U
${MAIN URL}             http://${HOST}:${PORT}

${GITHUB LOGIN}
${GITHUB PASSWORD}
${GITHUB USERNAME}      None

${DBNAME}         almalinux-bs
${DBPASS}         password
${DBPORT}         5432
${DBUSER}         postgres

${WAIT_ELEMENT_TIMEOUT}         1 min 30 s
