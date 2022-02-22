import { React, Component } from "react";
import { Grid, Box } from "@material-ui/core"
import InputLabel from '@mui/material/InputLabel';
import MenuItem from '@mui/material/MenuItem';
import FormControl from '@mui/material/FormControl';
import Select from '@mui/material/Select';
import TextField from '@mui/material/TextField';


export default class ApplicationTable extends Component {

    constructor(props) {
        super(props);
        this.state = {

        };
    }

    componentDidMount() {

    }


    render() {
        return (
            <Grid item xs={6} className="app-table-container">
                <div className="table-header-container">
                    <div className="card-title">
                        <h3>Appliocations</h3>
                    </div>

                    <div className="table-filter">
                        <div>
                            {/* <input
                            placeholder={`Search...`}
                            style={{
                                fontSize: '14px',
                                border: '0',
                                padding: "8px"
                            }}
                        /> */}
                        </div>


                        <div style={{backgroundColor:"white", height:"60px", padding:"10px"}}>
                            <TextField
                                id="filled-search"
                                label="Search field"
                                type="search"
                                variant="filled"
                                style={{ width: "180px" }}
                            />
                            <TextField
                                id="outlined-select-currency-native"
                                select
                                label="Native select"

                                SelectProps={{
                                    native: true,
                                }}
                                style={{ width: "180px" }}

                            >

                            </TextField>
                        </div>

                    </div>

                </div>
                <table className="app-table">
                    <tr>
                        <th>Company</th>
                        <th>Contact</th>
                        <th>Country</th>
                    </tr>
                    <tr>
                        <td>Alfreds Futterkiste</td>
                        <td>Maria Anders</td>
                        <td>Germany</td>
                    </tr>
                    <tr>
                        <td>Centro comercial Moctezuma</td>
                        <td>Francisco Chang</td>
                        <td>Mexico</td>
                    </tr>
                    <tr>
                        <td>Ernst Handel</td>
                        <td>Roland Mendel</td>
                        <td>Austria</td>
                    </tr>
                    <tr>
                        <td>Island Trading</td>
                        <td>Helen Bennett</td>
                        <td>UK</td>
                    </tr>
                    <tr>
                        <td>Laughing Bacchus Winecellars</td>
                        <td>Yoshi Tannamuri</td>
                        <td>Canada</td>
                    </tr>
                    <tr>
                        <td>Magazzini Alimentari Riuniti</td>
                        <td>Giovanni Rovelli</td>
                        <td>Italy</td>
                    </tr>
                </table>
            </Grid>
        );
    }
}
