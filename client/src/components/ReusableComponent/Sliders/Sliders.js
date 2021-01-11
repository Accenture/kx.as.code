import React from 'react';
import PropTypes from 'prop-types';
import { withStyles, makeStyles } from '@material-ui/core/styles';
import Slider from '@material-ui/core/Slider';
import Typography from '@material-ui/core/Typography';
import Tooltip from '@material-ui/core/Tooltip';
import './Sliders.scss';

const useStyles = makeStyles((theme) => ({
  root: {
    width: 300 + theme.spacing(3) * 2,
  },
  margin: {
    height: theme.spacing(3),
  },
}));

function ValueLabelComponent(props) {
  const { children, open, value } = props;

  return (
    <Tooltip open={open} enterTouchDelay={0} placement="top" title={value}>
      {children}
    </Tooltip>
  );
}

ValueLabelComponent.propTypes = {
  children: PropTypes.element.isRequired,
  open: PropTypes.bool.isRequired,
  value: PropTypes.number.isRequired,
};





const PrettoSlider = withStyles({
  root: {
    color: '#141A23',
    height: 1,
    display:'flex',
    alignItem:'center',
  },
  thumb: {
    height: 18,
    width: 18,
    backgroundColor: '#4683fa',
    border: '1px solid #4683fa',
    marginTop: -8,
    marginLeft: -12,
    '&:focus, &:hover, &$active': {
      boxShadow: 'inherit',
    },
  },
  active: {},
  valueLabel: {
    left: 'calc(-50% + 1px)',
  },
  track: {
    height: 8,
    borderRadius: 4,
  },
  rail: {
    height: 8,
    borderRadius: 4,
  },
})(Slider);


export default function CustomizedSlider(props) {
  const classes = useStyles();

  return (
    <div className={classes.root}>
      <div className='sliders'>
        <p>{props.name}</p>
        <p>{props.size}</p>
      </div>
      <Typography gutterBottom>{props.label}</Typography>
      <PrettoSlider valueLabelDisplay="auto" aria-label="pretto slider" defaultValue={props.defaultValue} min={props.min} max={props.max} onChange={props.handleChange}/>
      <div className={classes.margin} />
    </div>
  );
}