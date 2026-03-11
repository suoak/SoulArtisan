import React from 'react';
import Navbar from '../layout/Navbar';
import Hero from './Hero';
import Features from './Features';
import Pricing from './Pricing';
import Footer from '../layout/Footer';

const Home: React.FC = () => {
  return (
    <>
      <Navbar />
      <Hero />
      <Features />
      <Pricing />
      <Footer />
    </>
  );
};

export default Home;